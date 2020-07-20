import 'package:apple_sign_in/apple_id_credential.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FacebookSignInCredentials{
  String email;
  String accessToken;
  FacebookSignInCredentials(this.email, this.accessToken);
}

class AppleSignInCredentials{
  String email;
  String authCode;
  String idToken;
  AppleSignInCredentials({this.email, this.authCode, this.idToken});

  factory AppleSignInCredentials.fromAppleCreds(AppleIdCredential creds) {
    return AppleSignInCredentials(email: creds.email, idToken: String.fromCharCodes(creds.identityToken) ?? creds.user, authCode: String.fromCharCodes(creds.authorizationCode));
  }
  factory AppleSignInCredentials.fromLoginCreds(LogInCreds creds) {
    return AppleSignInCredentials(email: creds.email, idToken: creds.idToken, authCode: creds.passwordOrAccessToken);
  }
}

class GoogleSignInCredentials {
  String accessToken;
  String idToken;
  String email;

  GoogleSignInCredentials(
      {this.accessToken, this.idToken, this.email});

  factory GoogleSignInCredentials.fromSignIn(GoogleSignInAuthentication signIn, String email){
    return GoogleSignInCredentials(
      accessToken: signIn.accessToken,
      idToken: signIn.idToken,
      email: email,
    );
  }
}

class LogInCreds {
  String email;
  String idToken;
  String passwordOrAccessToken;
  String provider;
  LogInCreds(this.email, this.idToken, this.passwordOrAccessToken, this.provider);

  factory LogInCreds.fromRow(Map<String, dynamic> row) {
    return LogInCreds(
      row['email'],
      row['fuckingGoogleIdToken'],
      row['pass'],
      row['provider']
    );
  }
}
