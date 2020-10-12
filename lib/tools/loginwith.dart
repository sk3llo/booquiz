import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/models/loginCreds.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:stack_trace/stack_trace.dart';
import 'globals.dart';
import 'package:crypto/crypto.dart';

// EMAIL AND PASS

Future<FirebaseUser> loginWithEmailAndPassword(String email, String password) async {
  FirebaseUser _signedIn;

  try {


    _signedIn = await createUserWithEmailAndPassword(email, password);
  } catch (e) {
    // If already signed id
    if (e is PlatformException && e != null && e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
      _signedIn = await signInWithEmailAndPassword(email, password, _signedIn);
      // If wrong password or email display error
      if (e is PlatformException && e != null && e.code == 'ERROR_WRONG_PASSWORD' ||
          e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
        throw Exception('Wrong email or password');
      }
      bookDebug('loginwith.dart', 'loginWithEmailAndPassword', 'ERROR', e.toString());
      // Error for invalid email
    } else if (e is PlatformException && e.code == 'ERROR_INVALID_EMAIL') {
      throw Exception('Wrong email or password');
    } else {
      bookDebug('loginwith.dart', 'loginWithEmailAndPassword', 'ERROR', e.toString());
    }
  }
  return _signedIn;
}

Future<FirebaseUser> signInWithEmailAndPassword(
    String email, String password, FirebaseUser _signedIn) async {
  try {
    bookDebug('loginwith.dart', 'signInWithEmailAndPassword', 'INFO',
        'Trying to log in with Email and Password');
    AuthResult authresult =
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    if (authresult == null) {
      bookDebug('loginwith.dart', 'signInWithEmailAndPassword', 'ERROR', 'Error: login cancelled');
    } else {
      try {
        LogInCreds checkExists = await dbHelper.checkLogin();
        if (checkExists == null) {
          await dbHelper.saveLoginCreds(email, password, emailProvider);
        }
        _signedIn = authresult.user;
      } catch (e) {
        bookDebug('loginwith.dart', 'signInWithEmailAndPassword', 'ERROR', e.toString());
      }
    }
    return _signedIn;
  } catch (e) {
    bookDebug('loginwith.dart', 'signInWithEmailAndPassword', 'ERROR', e.toString());
  }
}

// GOOGLE

Future<FirebaseUser> loginWithGoogleCreds({@required GoogleSignInCredentials credentials}) async {
  assert(credentials != null);
  AuthResult authResult;

  try {
    // Try to sign in silently
    GoogleSignInAccount googleUser = await GoogleSignIn().signInSilently();
    if (googleUser != null) {
      var _googleAuth = await googleUser.authentication;
      authResult = await auth
          .signInWithCredential(GoogleAuthProvider.getCredential(
            accessToken: _googleAuth.accessToken,
            idToken: _googleAuth.idToken,
          ))
          .timeout(Duration(seconds: 10));
    } else {
      authResult = await auth
          .signInWithCredential(GoogleAuthProvider.getCredential(
            accessToken: credentials.accessToken,
            idToken: credentials.idToken,
          ))
          .timeout(Duration(seconds: 10));
    }

    firebaseUser = authResult.user;
    bookDebug('loginwith.dart', 'loginWithGoogleCreds', 'GOOGLE USER', firebaseUser.displayName);
    return firebaseUser;
  } catch (e) {
    if (e is PlatformException && e.code == 'ERROR_INVALID_CREDENTIAL') {
      bookDebug(
        'loginwith.dart',
        'loginWithGoogleCreds',
        'INFO',
        'GOOGLE TOKEN EXPIRED. REAUTHENTIFICATING...',
      );
      var _creds = await getGoogleAuthCredentials();
      if (_creds != null) {
        authResult = await auth
            .signInWithCredential(GoogleAuthProvider.getCredential(
              accessToken: credentials.accessToken,
              idToken: credentials.idToken,
            ))
            .timeout(Duration(seconds: 10));

        bookDebug(
          'loginwith.dart',
          'loginWithGoogleCreds',
          'SUCCESS',
          'Signed in firebase auth with user: ${authResult.user.displayName}, email: ${authResult.user.email}',
        );

        firebaseUser = authResult.user;
      } else {
        bookDebug('loginwith.dart', 'loginWithGoogleCreds', 'INFO',
            'GOOGLE TOKEN EXPIRED. REAUTHENTIFICATING FAILED');
      }
    } else {
      bookDebug(
        'loginwith.dart',
        'loginWithGoogleCreds',
        'ERROR',
        '$e',
      );
    }
  }
  return firebaseUser;
}

/// Returns Google Credetials while writing things to the secure storage
Future<GoogleSignInCredentials> getGoogleAuthCredentials() async {
  try {
    GoogleSignInCredentials creds;
    GoogleSignInAccount googleUser = await GoogleSignIn().signInSilently();
    if (googleUser == null) {
      await dbHelper.eraseLogin();
      bookDebug('loginwith.dart', 'getGoogleAuthCredentials', 'ERROR',
          'Google Login Error - invalid accessToken');
    } else {
      creds = GoogleSignInCredentials.fromSignIn(await googleUser.authentication, googleUser.email);

      await dbHelper.saveLoginCreds(creds.email, creds.accessToken, googleProvider);

      // Try to log in
      bookDebug(
        "loginWith.dart",
        'getGoogleAuthCredentials',
        'SUCCESS',
        'Google got google auth credentials',
      );
    }
    return creds;
  } catch (e) {
    bookDebug("loginWith.dart", 'getGoogleAuthCredentials', 'ERROR', e.toString());
  }
}

// GOOGLE
Future<FirebaseUser> signInWithGoogle() async {
  try {
    // Sign in with google
    var _signIn = await GoogleSignIn().signIn();
    if (_signIn != null) {
      // Check for duplicate email
      bool _duplicate = await fUtils.checkDuplicateEmail(_signIn.email);
      if (_duplicate){
        loginBloc.add(LoginErrorEvent(duplicateEmailError));
        return null;
      }

      var _auth = await _signIn.authentication;

      var creds = GoogleSignInCredentials(
          accessToken: _auth.accessToken, idToken: _auth.idToken, email: _signIn.email);

      var fireUser = await loginWithGoogleCreds(credentials: creds).catchError((e) async {
        if (e is PlatformException) {
          bookDebug(
              'loginwith.dart', 'signInWithGoogle', 'ERROR: e is PlatformException', e.message);
          // Check for duplicate email
//          loginBloc.add(LoginErrorEvent(e.message));
        } else {
          bookDebug('loginwith.dart', 'signInWithGoogle', 'ERROR', e.toString());
        }
      });
      if (fireUser == null) return null;

      await dbHelper.saveLoginCreds(creds.email, creds.accessToken, googleProvider, idToken: creds.idToken);

      return fireUser;
    }
  } catch (e) {
    bookDebug('loginwith.dart', 'signInWithGoogle', 'ERROR', e.toString());
  }
}

// APPLE
Future<FirebaseUser> signInWithApple(String idToken, String accessToken) async {
  try {
    bookDebug('loginwith.dart', 'signInWithApple', 'INFO', 'Signing In with APPLE');

    OAuthProvider oAuthProvider =
    OAuthProvider(providerId: "apple.com");

    final AuthCredential credential = oAuthProvider.getCredential(
      idToken:
      idToken,
      accessToken:
      accessToken,
//      rawNonce: "${Random.secure().nextInt(1131313)}${Random.secure().nextInt(13131313)}"
    );

      AuthResult _res = await FirebaseAuth.instance
          .signInWithCredential(credential).catchError((e) {
      bookDebug('loginwith.dart', 'signInWithApple/signInWithCredential', 'ERROR', '$e');
    });

    if (_res != null) {
      firebaseUser = _res.user;
    }

  } catch (e) {
    if (e is PlatformException){
      // Wrong password means that account already exists
      if (e.code == 'ERROR_WRONG_PASSWORD' || e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL'){
        loginBloc.add(LoginErrorEvent(e.message));
      } else {
        bookDebug('loginwith.dart', 'signInWithApple', 'ERROR', '$e');
      }
    } else
      bookDebug('loginwith.dart', 'signInWithApple', 'ERROR', '$e');
  }

  return firebaseUser;
}

// FACEBOOK
Future<FirebaseUser> loginWithFacebook({String email, String accessToken}) async {
  FirebaseUser _signedIn;
  AuthResult authresult;

  try {
    if (email != null && accessToken != null) {
      FirebaseUser _currentUser = await auth.currentUser();

      if (_currentUser == null) {
        authresult =
        await auth.signInWithCredential(FacebookAuthProvider.getCredential(
          accessToken: accessToken,
        ));
        bookDebug(
          'loginwith.dart',
          'loginWithFacebook',
          'SUCCESS',
          'Signed in firebase auth with ${authresult.user.email}',
        );
        FacebookSignInCredentials creds = FacebookSignInCredentials(accessToken, email);
        await dbHelper.saveLoginCreds(creds.email, creds.accessToken, fbProvider);
        _signedIn = authresult.user;
        return _signedIn;
      } else {
        return _currentUser;
      }
    } else {
      final facebookLogin = FacebookLogin();
      final result = await facebookLogin.logIn(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          authresult = await FirebaseAuth.instance
              .signInWithCredential(FacebookAuthProvider.getCredential(
            accessToken: result.accessToken.token,
          ))
              .catchError((e) async {
            if (e is PlatformException) {
              // Check for duplicate email
              if (e.code == 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL'){
                bookDebug('loginwith.dart', 'loginWithFacebook', 'ERROR', 'Account already exist');
                loginBloc.add(LoginErrorEvent(e.message));
                return null;
              }
            }
          });
          if (authresult == null) return null;
          _signedIn = authresult.user;

          final token = result.accessToken.token;
          final graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
          final profile = json.decode(graphResponse.body);

          FacebookSignInCredentials creds = FacebookSignInCredentials(result.accessToken.token, profile['email']);

          await dbHelper.saveLoginCreds(creds.email, creds.accessToken, fbProvider);
          break;
        case FacebookLoginStatus.cancelledByUser:
          throw ('FBLogin cancelled by the user');
        case FacebookLoginStatus.error:
          throw (result.errorMessage);
      }
    }
    return _signedIn;
  } catch (e) {

    if (e is PlatformException && e.code == 'ERROR_INVALID_CREDENTIAL') {
      loginBloc.add(LogOutEvent());
    }

    bookDebug('loginwith.dart', 'loginWithFacebook', 'ERROR', '$e');
    return null;
  }
}

Future<FirebaseUser> createUserWithEmailAndPassword(
    String email, String password) async {
  try {
    AuthResult authResult = await auth.createUserWithEmailAndPassword(email: email, password: password);
    if (authResult == null) {
      bookDebug('loginwith.dart', 'createUserWithEmailAndPassword', 'ERROR', 'Error: login cancelled');
    }
    return authResult.user;
  } catch (e) {
    if (e is PlatformException && e.code == 'ERROR_EMAIL_ALREADY_IN_USE')
      loginBloc.add(LoginErrorEvent(e.message));
    bookDebug(
      "loginWith.dart",
      'createUserWithEmailAndPassword',
      'ERROR',
      '$e',
    );
  }
}
