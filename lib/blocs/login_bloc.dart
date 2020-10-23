import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:booquiz/models/loginCreds.dart';
import 'package:booquiz/models/UserModel.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/tools/loginwith.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class LoginEvents extends Equatable {
  LoginEvents([List props = const []]) : super();
}

// Empty event
class LoginEmptyEvent extends LoginEvents {
  @override
  List<Object> get props => [];
}

// Try to log in
class TryToLogInEvent extends LoginEvents {
  @override
  List<Object> get props => [];
}

// Switch to email page or not
class LoginWannaLeaveEvent extends LoginEvents {
  // Preserve the state to recover if user wans to switch back
  final LoggedInState savedLoadedState;
  final bool shouldYield;

  LoginWannaLeaveEvent(this.savedLoadedState, {this.shouldYield = false});

  @override
  List<Object> get props => [savedLoadedState, shouldYield];
}

// Error event
class LoginErrorEvent extends LoginEvents {
  final LoggedInState oldLoggedState; // Whether username or global error
  final bool usernameError; // Whether username or global error
  final String message;

  LoginErrorEvent(this.message, {this.usernameError = false, this.oldLoggedState});

  @override
  List<Object> get props => [message, usernameError, oldLoggedState];
}

// FB LOGIN
class FBLogInEvent extends LoginEvents {
  final bool onStart; // Whether called on app start

  FBLogInEvent({this.onStart = false});

  @override
  List<Object> get props => [onStart];
}

// GOOGLE LOG IN
class GoogleLogInEvent extends LoginEvents {
  final bool onStart; // Whether called on app start

  GoogleLogInEvent({this.onStart = false});

  @override
  List<Object> get props => [onStart];
}

// APPLE LOG IN
class AppleLogInEvent extends LoginEvents {
  final bool onStart; // Whether called on app start

  AppleLogInEvent({this.onStart = false});

  @override
  List<Object> get props => [onStart];
}

// EMAIL AND PASS LOGIN
class EmailPassLogInEvent extends LoginEvents {
  final String email;
  final String password;
  final bool onStart; // Whether called on app start

  EmailPassLogInEvent({this.email, this.password, this.onStart = false});

  @override
  List<Object> get props => [email, password, onStart];
}

// CREATE NEW USER
class CreateNewUser extends LoginEvents {
  final FirebaseUser user;
  final String loginMethod;
  final String username;
  final String password;

  CreateNewUser(this.user, this.loginMethod, this.username, this.password);

  @override
  List<Object> get props => [user, loginMethod, username, password];
}

// LOG OUT
class LogOutEvent extends LoginEvents {
  @override
  List<Object> get props => [];
}

/// STATES

@immutable
abstract class LoginStates extends Equatable {
  LoginStates([List props = const []]) : super();
}

class LoginEmptyState extends LoginStates {
  final bool triedToLogIn;

  LoginEmptyState({this.triedToLogIn = false});

  @override
  List<Object> get props => [triedToLogIn];
}

// LOADING
class LoginLoadingState extends LoginStates {
  @override
  List<Object> get props => [];
}

// LOGGED IN
class LoggedInState extends LoginStates {
  final UserModel user;
  final String loginMethod;
  final bool newUser;

  LoggedInState(this.user, this.loginMethod, this.newUser);

  @override
  List<Object> get props => [user, newUser, loginMethod];
}

// ERROR STATE
class LoginErrorState extends LoginStates {
  final bool usernameError;
  final LoggedInState oldLoggedState; // If user wants to go back retrieve the state
  final String message;

  LoginErrorState(this.message, {this.usernameError = false, this.oldLoggedState});

  @override
  List<Object> get props => [message, usernameError, oldLoggedState];
}

// NEW USER CREATED STATE
class NewUserCreatedState extends LoginStates {
  final UserModel user;

  NewUserCreatedState(this.user);

  @override
  List<Object> get props => [user];
}

/// BLOC

class LoginBloc extends Bloc<LoginEvents, LoginStates> {
  LoginBloc() : super(LoginEmptyState());

//  LoginEmptyState
  @override
  Stream<LoginStates> mapEventToState(LoginEvents event) async* {

    // Null all states (useful after error)
    if (event is LoginEmptyEvent) {
      yield LoginEmptyState();
    }

    // Error message
    if (event is LoginErrorEvent) {
      yield LoginErrorState(event.message,
          usernameError: event.usernameError, oldLoggedState: event.oldLoggedState);
    }

    // LOG OUT
    if (event is LogOutEvent) {
      yield LoginLoadingState();

      try {
        LogInCreds _loggedIn = await dbHelper.checkLogin();

        if (_loggedIn != null) {
          // Check FB login
          if (_loggedIn.provider == fbProvider) {
//            await ssActs.eraseFacebookLogin();
            await dbHelper.eraseLogin();
            await FacebookLogin().logOut();
            await auth.signOut();
            currentUser = null;
            bookDebug('login_bloc.dart', 'LogOutEvent', 'INFO', 'SIGNED OUT FROM FACEBOOK');
          }
          // Check Google login
          if (_loggedIn.provider == googleProvider) {
//            await ssActs.eraseGoogleLogin();
            await dbHelper.eraseLogin();
            await GoogleSignIn().signOut();
            await auth.signOut();
            currentUser = null;
            bookDebug('login_bloc.dart', 'LogOutEvent', 'INFO', 'SIGNED OUT FROM GOOGLE');
          }
          // Check Email login
          if (_loggedIn.provider == emailProvider) {
//            await ssActs.eraseEmailPassLogin();
            await dbHelper.eraseLogin();
            await auth.signOut();
            currentUser = null;
            bookDebug('login_bloc.dart', 'LogOutEvent', 'INFO', 'SIGNED OUT FROM EMAIL AND PASS');
          }

          // Check Apple login
          if (_loggedIn.provider == appleProvider) {
//            await ssActs.eraseAppleLogin();
            await dbHelper.eraseLogin();
            await auth.signOut();
            currentUser = null;
            bookDebug('login_bloc.dart', 'LogOutEvent', 'INFO', 'SIGNED OUT FROM APPLE');
          }
        } else {
          bookDebug('login_bloc.dart', 'LogOutEvent', 'INFO', 'NO ONE TO LOG OUT');
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'LogOutEvent', 'ERROR', e.toString());
      }

      yield LoginEmptyState();
    }

    // TRY TO LOG IN
    if (event is TryToLogInEvent) {

      LogInCreds _loggedIn = await dbHelper.checkLogin();

      bookDebug('login_bloc.dart', 'TryToLogInEvent', 'INFO', 'Trying to log in...');

      if (_loggedIn != null) {
        // Check FB login
        if (_loggedIn.provider == 'FB') {
          this.add(FBLogInEvent(onStart: true));
          return;
        }
        // Check Google login
        if (_loggedIn.provider == 'GOOGLE') {
          this.add(GoogleLogInEvent(onStart: true));
          return;
        }
        // Check Apple login
        if (_loggedIn.provider == 'APPLE') {
          this.add(AppleLogInEvent(onStart: true));
          return;
        }
        // Check Email login
        if (_loggedIn.provider == 'EMAIL') {
          this.add(EmailPassLogInEvent(onStart: true));
          return;
        }
        bookDebug('login_bloc.dart', 'TryToLogInEvent', 'INFO',
            'USER LOGGED OUT AND HAVEN`T LOGGED IN YET');
      } else {
        bookDebug('login_bloc.dart', 'TryToLogInEvent', 'INFO', 'No saved loggin records found');
        yield LoginEmptyState(triedToLogIn: true);
      }

    }

    // FB LOGIN
    if (event is FBLogInEvent) {
      yield LoginLoadingState();

      try {
        bookDebug('login_bloc.dart', 'FBLogInEvent', 'INFO', 'Loggin in with Facebook...');
        LogInCreds creds = await dbHelper.checkLogin();
        // Check if local data exists
        if (creds != null && creds.provider == fbProvider) {
          firebaseUser = await loginWithFacebook(email: creds.email, accessToken: creds.passwordOrAccessToken);

          if (firebaseUser != null) {
            // Search for user in firestore
            currentUser = await fUtils.getUser(firebaseUser.email);

            // No user in firestore but local data exists
            if (currentUser == null) {
              bookDebug('login_bloc.dart', 'FBLogInEvent', 'INFO',
                  'No user in firestore but logged in: show `choose username` screen');

              // Create new model
              currentUser = UserModel(
                  email: creds.email,
                  password: creds.passwordOrAccessToken,
                  loginMethod: [fbProvider]
              );
              yield LoggedInState(currentUser, fbProvider, true);
              return;
            } else if (!currentUser.loginMethod.contains(fbProvider)){
              currentUser.loginMethod.add(fbProvider);
              await currentUser.snap.reference.updateData({
                'loginMethod': currentUser.loginMethod
              });
            }

            // Update `lastLogin` timestamp
//            await currentUser.snap.reference.setData({'lastLogin': Timestamp.now()}, merge: true);

            bookDebug('login_bloc.dart', 'FBLogInEvent', 'INFO',
                'Successfully logged in: ${currentUser.email}');
            yield LoggedInState(currentUser, fbProvider, false);
            return;
          }
          yield LoginEmptyState();
          return;
        }
        if (event.onStart)
          throw (Error()); // Don't show login pop up on start, only login with creds if exists

        firebaseUser = await loginWithFacebook();

        if (firebaseUser != null) {
          currentUser = await fUtils.getUser(firebaseUser.email);
          if (currentUser == null) {
            // MOST LIKELY NEW USER
            bookDebug('login_bloc.dart', 'FBLoginEvent', 'INFO',
                'NO USER IF FIRESTORE. MOST LIKELY A NEW ONE');

            LogInCreds _creds = await dbHelper.checkLogin();

            // Create new model
            currentUser = UserModel(
                email: _creds.email,
                password: _creds.passwordOrAccessToken,
                loginMethod: [fbProvider]
            );
          } else if (!currentUser.loginMethod.contains(fbProvider)){
            currentUser.loginMethod.add(fbProvider);
            await currentUser.snap.reference.updateData({
              'loginMethod': currentUser.loginMethod
            });
          }

          yield LoggedInState(currentUser, fbProvider, true);
        } else {
          yield LoginEmptyState();
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'FBLoginEvent', 'ERROR', '$e');
        yield LoginEmptyState();
      }
    }

    // GOOGLE LOGIN
    if (event is GoogleLogInEvent) {
      yield LoginLoadingState();

      try {
        bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO', 'Loggin in with Google...');

        LogInCreds creds = await dbHelper.checkLogin();

        // Check if local data exists
        if (creds != null && creds.provider == googleProvider) {
          bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO', 'FOUND EXISTING CREDENTIALS');
          firebaseUser = await loginWithGoogleCreds(
              credentials: GoogleSignInCredentials(
                  accessToken: creds.passwordOrAccessToken, idToken: creds.idToken, email: creds.email));

          if (firebaseUser != null) {
            // Search for user in firestore
            currentUser = await fUtils.getUser(firebaseUser.email);

            if (currentUser == null) {
              bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO',
                  'New user: show `choose username` screen');

              // Create new model
              currentUser = UserModel(
                  email: creds.email,
                  password: creds.passwordOrAccessToken,
                  loginMethod: [googleProvider]
              );
              yield LoggedInState(currentUser, googleProvider, true);
              return;
              // Check if Google login is in [loginMethods]
            } else if (!currentUser.loginMethod.contains(googleProvider)){
              currentUser.loginMethod.add(googleProvider);
              await currentUser.snap.reference.updateData({
                'loginMethod': currentUser.loginMethod
              });
            }

            // Update timestamp
            await currentUser.snap.reference.setData({'lastLogin': Timestamp.now()}, merge: true);

            bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO',
                'Successfully logged in: ${currentUser.email}');

            yield LoggedInState(currentUser, googleProvider, false);
            return;
          }
          // yield if error
          yield LoginEmptyState();
          return;
        }

        bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO',
            'NO EXISTING CREDENTIALS FOUND. PROCEED...');

        if (event.onStart)
          throw (Error()); // Don't show login pop up on start, only login with creds if exists

        // First time sign in
        firebaseUser = await signInWithGoogle();

        if (state is LoginErrorState) return;

        if (firebaseUser != null) {
          currentUser = await fUtils.getUser(firebaseUser.email);
          if (currentUser == null) {
            // MOST LIKELY NEW USER
            bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'INFO',
                'NO USER IF FIRESTORE. MOST LIKELY A NEW ONE');

            // Create new model
            currentUser = UserModel(
                email: firebaseUser.email,
                loginMethod: [googleProvider]
            );
            // Check if Google login is in [loginMethods]
          } else if (!currentUser.loginMethod.contains(googleProvider)){
            currentUser.loginMethod.add(googleProvider);
              await currentUser.snap.reference.updateData({
                'loginMethod': currentUser.loginMethod
              });
          }
          yield LoggedInState(currentUser, googleProvider, true);
        } else {
          yield LoginEmptyState();
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'GoogleLogInEvent', 'ERROR', e.toString());
        yield LoginEmptyState();
      }
    }

    // APPLE LOGIN
    if (event is AppleLogInEvent) {
      yield LoginLoadingState();

      try {
        bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO', 'Loggin in with Apple...');

        LogInCreds loggedIncreds = await dbHelper.checkLogin();

        if (loggedIncreds != null && loggedIncreds.provider == appleProvider) {
          bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO', 'FOUND EXISTING CREDENTIALS');
          await signInWithApple(loggedIncreds.idToken, loggedIncreds.passwordOrAccessToken);
          // Search for user in firestore
          currentUser = await fUtils.getUser(firebaseUser.email);

          if (currentUser == null) {
            bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO',
                'New user: show `choose username` screen');

            // Create new model
            currentUser = UserModel(
                email: loggedIncreds.email,
                password: loggedIncreds.passwordOrAccessToken,
                loginMethod: [appleProvider]
            );
            yield LoggedInState(currentUser, appleProvider, true);
            return;
          }

          // Update timestamp
          await currentUser.snap.reference.setData({'lastLogin': Timestamp.now()}, merge: true);

          bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO',
              'Successfully logged in: ${currentUser.email}');

          yield LoggedInState(currentUser, appleProvider, false);
          return;
        }

        if (event.onStart)
          throw (Error()); // Don't show login pop up on start, only login with creds if exists

        if (await AppleSignIn.isAvailable()) {
          final AuthorizationResult result = await AppleSignIn.performRequests([
            AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
          ]);

          // First time log in
          switch (result.status) {
            case AuthorizationStatus.authorized:

              AppleSignInCredentials creds = AppleSignInCredentials.fromAppleCreds(result.credential);

              // Sign in and assign Firebase User
              await signInWithApple(creds.idToken, creds.authCode);

              if (creds.email == null || creds.email == ''){
                // Try to get hidden email if normal one doesn't work
                var x = parseJwt(AsciiCodec().decode(result.credential.identityToken));
                creds.email = x['email'];
              }

              // Save creds to DB
              await dbHelper.saveLoginCreds(firebaseUser.email, creds.authCode, appleProvider, idToken: creds.idToken);

              // On error
              if (firebaseUser == null && state is LoginErrorState){
                return;
              }

              // Search for user in firestore
              currentUser = await fUtils.getUser(firebaseUser.email);

              if (currentUser == null) {
                bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO',
                    'New user: show `choose username` screen');

                // Create new model
                currentUser = UserModel(
                  email: creds.email,
                  password: creds.authCode,
                  loginMethod: [appleProvider]
                );
                yield LoggedInState(currentUser, appleProvider, true);
                return;
              }
              break;
            case AuthorizationStatus.error:
              bookDebug('login_bloc.dart', 'Apple Login', 'ERROR', result.error.localizedDescription);

              if (AuthorizationStatus.error.index == 2) {
                yield LoginEmptyState();
                break;
              }
              yield LoginErrorState('"Sign in failed');
              break;
            case AuthorizationStatus.cancelled:
              print('User cancelled');
              yield LoginEmptyState();
              break;
          }
        } else {
          bookDebug('login_bloc.dart', 'Apple Login', 'ERROR', 'Apple Sign In is not available for your device');
          yield LoginErrorState('Apple Sign In is not available for your device');
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'AppleLogInEvent', 'ERROR', '$e');
        // If trying to create accounts with the same email and different providers
        if (e is PlatformException)
          yield LoginErrorState(e.details);
         else
          yield LoginEmptyState();
      }
    }

    // EMAIL AND PASS LOGIN
    if (event is EmailPassLogInEvent) {
      yield LoginLoadingState();

      try {
        bookDebug(
            'login_bloc.dart', 'EmailPassLogInEvent', 'INFO', 'Loggin in with Email and Pass...');

        LogInCreds creds = await dbHelper.checkLogin();

        // Check if local data exists
        if (creds != null && creds.provider == emailProvider) {
          bookDebug('login_bloc.dart', 'EmailPassLogInEvent', 'INFO', 'FOUND EXISTING CREDENTIALS');
          var _res = await auth
              .signInWithEmailAndPassword(email: creds.email, password: creds.passwordOrAccessToken)
              .catchError((e) async {
            if (e is PlatformException) {
              if (e.code == 'ERROR_USER_NOT_FOUND') {
                await dbHelper.eraseLogin(); // Erase local data if exists
              }
            }
          });
          firebaseUser = _res.user;

          if (firebaseUser != null) {
            // Search for user in firestore
            currentUser = await fUtils.getUser(firebaseUser.email);

            // No user in firestore but logged in: show `choose username` screen
            if (currentUser == null) {
              bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO',
                  'New user: show `choose username` screen');

              // Create new model
              currentUser = UserModel(
                  email: creds.email,
                  password: creds.passwordOrAccessToken,
                  loginMethod: [emailProvider]
              );
              yield LoggedInState(currentUser, emailProvider, true);
              return;
            }

            // Update timestamp
            await currentUser.snap.reference.setData({'lastLogin': Timestamp.now()}, merge: true);

            bookDebug('login_bloc.dart', 'EmailPassLogInEvent', 'INFO',
                'Successfully logged in: ${currentUser.email}');

            yield LoggedInState(currentUser, emailProvider, false);
            return;
          }
          // yield if error
          yield LoginEmptyState();
          return;
        }

        if (event.onStart) throw (Error());

        bookDebug('login_bloc.dart', 'EmailPassLogInEvent', 'INFO',
            'NO EXISTING CREDENTIALS FOUND. PROCEED...');

        // Sign in with google
        String _errorMessage = '';
        var _signIn = await auth
            .createUserWithEmailAndPassword(email: event.email.trim(), password: event.password.trim())
            .catchError((e) {
          _errorMessage = e.message;
        });

        if (_errorMessage == 'The email address is already in use by another account.'){
          _errorMessage = ''; // Null error and try to sign in instead on creating account
          _signIn = await auth.signInWithEmailAndPassword(email: event.email, password: event.password).catchError((e){
            _errorMessage = e.message;
          });
        }

        if (_errorMessage.isNotEmpty) {   // Check for error
          yield LoginErrorState(_errorMessage);
          return;
        }
        if (_signIn != null) {
          firebaseUser = _signIn.user;
          if (firebaseUser != null) {
            await dbHelper.saveLoginCreds(event.email, event.password, emailProvider);
            currentUser = await fUtils.getUser(firebaseUser.email);
            if (currentUser == null) {
              bookDebug('login_bloc.dart', 'AppleLogInEvent', 'INFO',
                  'New user: show `choose username` screen');

              // Create new model
              currentUser = UserModel(
                  email: event.email,
                  password: event.password,
                  loginMethod: [emailProvider]
              );
            }
            yield LoggedInState(currentUser, emailProvider, true);
          }
        } else {
          yield LoginEmptyState();
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'EmailPassLogInEvent', 'ERROR', '$e');
        yield LoginEmptyState();
      }
    }

    // Create user in Firestore
    if (event is CreateNewUser) {
      try {
        if (event.user != null && event.username.isNotEmpty) {
          yield LoginLoadingState();

          var _user = await fUtils.createUser(
              event.loginMethod, event.username, event.password ?? '');

          yield NewUserCreatedState(_user);
        }
      } catch (e) {
        bookDebug('login_bloc.dart', 'CreateNewUser', 'ERROR', '$e');
      }
    }
  }
}

// Needed to decode JSON JWT Token to allow Apple login
String decodeBase64(String str) {
  String output = str.replaceAll('-', '+').replaceAll('_', '/');

  switch (output.length % 4) {
    case 0:
      break;
    case 2:
      output += '==';
      break;
    case 3:
      output += '=';
      break;
    default:
      throw Exception('Illegal base64url string!"');
  }

  return utf8.decode(base64Url.decode(output));
}

Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = decodeBase64(parts[1]);
  final payloadMap = json.decode(payload);
  if (payloadMap is! Map<String, dynamic>) {
    throw Exception('invalid payload');
  }

  return payloadMap;
}
