import 'package:booquiz/models/userModel.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class FirestoreUtils {

  // CREATE USER
  Future<UserModel> createUser(String loginMethod, String username, String password) async {
//    assert(user != null);

    bookDebug('firestore_utils.dart', 'createUser', 'INFO', 'Trying to create user: ${firebaseUser.email}');

    List<String> _usernameSearch = await generateDisplayNameAndUsername(username.toLowerCase());

    try {
      UserModel _user = UserModel.newUser(firebaseUser, loginMethod, username, password, _usernameSearch);
      currentUser = _user;

      var _data = {
        'username': username,
        'usernameLower': username.toLowerCase(), // Needed for filter
        'usernameSearch': _usernameSearch, // Needed for filter
        'email': _user.email,
        'aboutMe': '',
        'loginMethod': [loginMethod],
        'questionsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
        'lastLogin': Timestamp.now(),
      };

      if (loginMethod == emailProvider && password != null && password.isNotEmpty){
        _data.addAll({'password': password});
      }

      await usersRef.add(_data);

      return _user;
    } catch (e) {
      bookDebug('firestore_utils.dart', 'createUser', 'ERROR', '$e');
    }

  }
//
//  // CHECK EXIST USER
//  Future<bool> checkForExistingUser(String email) async {
//    bool exists = false;
//    try {
//      await usersRef.where('email', isEqualTo: email).getDocuments().then((d) {
//        if (d != null && d.documents.isNotEmpty) {
//          exists = true;
//        }
//      });
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'checkForExistingUser', 'ERROR', '$e');
//    }
//    return exists;
//  }
//
//  Future<DocumentSnapshot> checkBlocked(UserModel userToCheck) async {
//
//    try {
//      DocumentSnapshot myBlockDoc;
//
//      var query = await userToCheck.snap.reference.collection(reportedBy).where('ref', isEqualTo: currentUser.snap.reference.path).getDocuments();
//
//      if (query != null && query.documents.isNotEmpty)
//        myBlockDoc = query.documents.first;
//
//
//      return myBlockDoc;
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'checkBlocked', 'ERROR', '$e');
//    }
//
//  }
//
  // DUPLICATE USERNAME
  Future<bool> checkDuplicateUsername(String username) async {
    bool duplicate = false;
    try {
      await usersRef
          .where('usernameLower', isEqualTo: username)
          .getDocuments()
          .then((d) {
        if (d != null && d.documents.isNotEmpty) {
          duplicate = true;
        }
      });
    } catch (e) {
      bookDebug('firestore_utils.dart', 'checkDuplicateUsername', 'ERROR', '$e');
    }
    return duplicate;
  }

  // DUPLICATE EMAIL
  Future<bool> checkDuplicateEmail(String email) async {
    bool duplicate = false;

    try {
      await usersRef
          .where('email', isEqualTo: email)
          .getDocuments()
          .then((d) {
        if (d != null && d.documents.isNotEmpty) {
          duplicate = true;
        }
      });
    } catch (e) {
      bookDebug('firestore_utils.dart', 'checkDuplicateEmail', 'ERROR', '$e');
    }
    return duplicate;
  }

  // GET USER
  Future<UserModel> getUser(String email) async {
    UserModel user;
    try {
      await usersRef.where('email', isEqualTo: email).getDocuments().then((d) {
        if (d != null && d.documents.isNotEmpty) {
          user = UserModel.fromSnap(d.documents.first);
        }
      });
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getUser', 'ERROR', '$e');
    }

    return user;
  }

  /// NEEDED TO GENERATE 'searchName'

  Future<List<String>> generateDisplayNameAndUsername(String initialName) async {
    List<String> mainList = [];
    List<String> _words = [];
    // First check how many words we got
    // And generate separate collection of characters for each word
    if (initialName.contains(' ')) {
      _words.addAll(initialName.split(' '));

      await Future.forEach(_words, (w) async {
        // Now break each word into raising list of characters
        int _count = -1;
        await Future.forEach(w.split(''), (char) {
          _count += 1;
          mainList.add(w.substring(0, w.length - _count).toLowerCase());
        });
        // Finally add all broken words too
        mainList.addAll(w.toLowerCase().split(''));
      });
    } else {
      _words.add(initialName);

      if (_words.isNotEmpty) {
        await Future.forEach(_words, (w) async {
          // Now break each word into raising list of characters
          int _count = -1;
          await Future.forEach(w.split(''), (char) {
            _count += 1;
            mainList.add(w.substring(0, w.length - _count).toLowerCase());
          });
          if (_words.length > 1) {
            // Finally add all broken words too
            mainList.addAll(w.toLowerCase().split(''));
          }
        });
        mainList.addAll(initialName.toLowerCase().split(''));
      }
    }

    // And the last thing is adding raw name
    mainList.add(initialName.toLowerCase());

    return mainList;
  }

}