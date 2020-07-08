import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String username;
  final Timestamp lastLogin;
  final String email;
  final String password; // Used only if user logged in with Email/Password
  final List<String> loginMethod; // GOOGLE, APPLE, FB, EMAIL
  final List<String> questions; // Have to get manually
  final int questionsCount; // Have to get manually
  final List<String> usernameSearch;
  final DocumentSnapshot snap;
//  List<String> reportedBy; // List of users who reported this one

  UserModel({this.username, this.usernameSearch, this.lastLogin, this.email, this.password, this.loginMethod, this.questions, this.questionsCount,
      this.snap,
//    this.reportedBy
  });

  factory UserModel.fromSnap(DocumentSnapshot _snap) {
    return UserModel(
      username: _snap.data['username'],
      email: _snap.data['email'],
      loginMethod: List<String>.from(_snap.data['loginMethod']),
      snap: _snap,
      lastLogin: _snap.data['lastLogin'],
      password: _snap.data['password'] ?? '',
      usernameSearch: List<String>.from(_snap.data['usernameSearch'] ?? []),
      questionsCount: _snap.data['questionsCount'] ?? 0
//      reportedBy: List<String>.from(_snap.data['reportedBy'] ?? []),
    );
  }

  factory UserModel.newUser(
      FirebaseUser _user, String loginMethod, String username, String password, List<String> usernameSearch) {
    return UserModel(
      username: username,
      email: _user.email,
      loginMethod: [loginMethod],
      password: password ?? '',
      lastLogin: Timestamp.now(),
      questionsCount: 0,
      usernameSearch: usernameSearch,
    );
  }

}
