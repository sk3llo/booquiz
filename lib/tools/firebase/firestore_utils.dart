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
        'loginMethod': [loginMethod],
        'questionsCount': 0,
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
//
//  // LIKE STRAIN
//  Future<bool> likeStrain(StrainItemModel strain) async {
//    bool successfullyLiked = false;
//    try {
//      var _like = await _checkLike(strain);
//
//      // First like
//      if (_like == null) {
//        var _newLike;
//        // First increment `likesAmount`
//        await firestore.document(strain.docRef).setData({
//          'likesAmount': strain.likesAmount + 1
//        }, merge: true);
//
//        // Now add my new like as a doc to `LIKES` collection
//        _newLike = await firestore.document(strain.docRef).collection('LIKES').add({
//          'ref': currentUser.snap.reference.path,
//          'like': true,
//          'timestamp': Timestamp.now(),
//        });
//        if (_newLike != null)
//          successfullyLiked = true;
//        bookDebug('firestore_utils.dart', 'likeStrain', 'INFO', 'Successfully liked: ${_newLike?.documentID}');
//
//        // If not liked
//      } else if (_like != null && !_like.data['like']) {
//        // First increment `likesAmount`
//        await firestore.document(strain.docRef).setData({
//          'likesAmount': strain.likesAmount + 1
//        }, merge: true);
//
//        _like.reference.updateData({
//          'ref': currentUser.snap.reference.path,
//          'like': true,
//          'timestamp': Timestamp.now(),
//        });
//        successfullyLiked = true;
//        bookDebug('firestore_utils.dart', 'likeStrain', 'INFO', 'Successfully liked: ${_like.documentID}');
//      } else {
//        bookDebug('firestore_utils.dart', 'likeStrain', 'INFO', 'CANNOT LIKE TWICE!');
//      }
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'likeStrain', 'ERROR', '$e');
//    }
//
//    strain.likesAmount += 1;
//    return successfullyLiked;
//  }
//
//  // DISLIKE STRAIN
//  Future<bool> dislikeStrain(StrainItemModel strain) async {
//    try {
//      DocumentSnapshot _like = await _checkLike(strain);
//
//      // If liked
//      if (_like != null && _like.data['like']) {
//        // First decrement `likesAmount`
//        await firestore.document(strain.docRef).setData({
//          'likesAmount': strain.likesAmount - 1
//        }, merge: true);
//
//        _like.reference.updateData({
//          'ref': currentUser.snap.reference.path,
//          'like': false,
//          'timestamp': Timestamp.now(),
//        });
//        bookDebug('firestore_utils.dart', 'dislikeStrain', 'INFO', 'Successfully disliked: ${_like.reference.documentID}');
//        strain.likesAmount -= 1;
//        return true;
//      } else {
//        bookDebug('firestore_utils.dart', 'dislikePost', 'INFO', 'DISLIKE CANCELLED. POST IS NOT LIKED YET!');
//      }
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'dislikePost', 'ERROR', '$e');
//    }
//
//    return false;
//  }
//
//  // CHECK LIKED
//  Future<DocumentSnapshot> _checkLike(StrainItemModel strain) async {
//    DocumentSnapshot like;
//
//    try {
//      var _docs = await firestore.document(strain.docRef).collection('LIKES')
//          .where('ref', isEqualTo: currentUser.snap.reference.path).getDocuments();
//      if (_docs != null && _docs.documents.isNotEmpty)
//        like = _docs.documents.first;
//    } catch (e) {
//      bookDebug('firestore_utils.dart', '_checkLike', 'ERROR', '$e');
//    }
//
//    return like;
//  }
//
//  // LOAD COMMENTS
//  Future<List<ReviewModel>> loadReviews(StrainItemModel strain, int limit, List<ReviewModel> reviews) async {
//    try {
//      QuerySnapshot _docs;
//      // If need to load more comments
//      if (reviews.isNotEmpty){
//        _docs = await firestore.document(strain.docRef).collection('REVIEWS')
//            .startAfterDocument(reviews.last.snap)
//            .limit(limit).getDocuments();
//      } else {
//        // First load
//        _docs = await firestore.document(strain.docRef).collection('REVIEWS')
//            .limit(limit).getDocuments();
//      }
//
//      if (_docs != null && _docs.documents.isNotEmpty){
//        await Future.forEach(_docs.documents, (doc) async {
//          var _review = ReviewModel.fromSnap(doc);
//          // Get user
//          _review.user = UserModel.fromSnap(await _review.reviewerRef.get());
//          // Check collapsed
//          var _checkBlocked = await fUtils.checkBlocked(_review.user);
//          _review.collapsed = _checkBlocked != null && _checkBlocked.data['blocked'];
//          reviews.add(_review);
//        });
//        reviews.sort((a, b) => a.timestamp.millisecondsSinceEpoch.compareTo(b.timestamp.millisecondsSinceEpoch));
//      }
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'loadReviews', 'ERROR', '$e');
//    }
//
//    return reviews;
//  }
//
  // ADD QUESTION
//  Future addQuestion(StrainItemModel strain, String text, List<ReviewModel> mainList, int rating) async {
//    DocumentReference _newComment;
//
//    try {
//      var _t = Timestamp.now();
//
//      // Add to strain REVIEWS
//       _newComment = await firestore.document(strain.docRef).collection('REVIEWS').add({
//        'ref': currentUser.snap.reference,
//        'rating': rating,
//        'text': text,
//        'timestamp': _t
//      });
//
//       // Update strain reviewsCount
//       await firestore.document(strain.docRef).setData({
//         'reviewsCount': currentUser.questionsCount + 1
//       }, merge: true);
//
//       // Add new doc to my REVIEWS collection
//       await currentUser.snap.reference.collection('REVIEWS').add({
//         'ref': currentUser.snap.reference.path,
//         'text' : text,
//         'rating': rating,
//         'timestamp': _t
//       });
//
//       // Update my list of reviews
//       await currentUser.snap.reference.updateData({
//         'reviewsCount': currentUser.questionsCount + 1
//       });
//
//
////       currentUser.questionsCount += 1;
//
//       if (mainList != null){
//         // Check collapsed
////         var _review = ReviewModel.fromSnap(await _newComment.get());
////         mainList.add(_review);
//         mainList.sort((a, b) => a.timestamp.millisecondsSinceEpoch.compareTo(b.timestamp.millisecondsSinceEpoch));
//         bookDebug('firestore_utils.dart', 'addReview', 'INFO', 'SUCCESSFULLY ADEED REVIEW TO: ${strain.docRef}');
//       }
//    } catch (e) {
//      bookDebug('firestore_utils.dart', 'addReview', 'ERROR', '$e');
//    }
//    return mainList;
//  }

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