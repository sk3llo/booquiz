import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/models/UserModel.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class FirestoreUtils {
  //                USER RELATED SHIT

  // CREATE USER
  Future<UserModel> createUser(String loginMethod, String username, String password) async {
//    assert(user != null);

    bookDebug('firestore_utils.dart', 'createUser', 'INFO',
        'Trying to create user: ${firebaseUser.email}');

    List<String> _usernameSearch = await generateDisplayNameAndUsername(username.toLowerCase());

    try {
      UserModel _user =
          UserModel.newUser(firebaseUser, loginMethod, username, password, _usernameSearch);
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

      if (loginMethod == emailProvider && password != null && password.isNotEmpty) {
        _data.addAll({'password': password});
      }

      await usersRef.add(_data);

      return _user;
    } catch (e) {
      bookDebug('firestore_utils.dart', 'createUser', 'ERROR', '$e');
    }
  }

  // DUPLICATE USERNAME
  Future<bool> checkDuplicateUsername(String username) async {
    bool duplicate = false;
    try {
      await usersRef.where('usernameLower', isEqualTo: username).getDocuments().then((d) {
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
      await usersRef.where('email', isEqualTo: email).getDocuments().then((d) {
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

  //                 USER BOOKS RELATED SHIT

  Future<List<Question>> getNotCompletedQuestions(String bookId, {int limit = 5, UserBook optionalLoadedUserBook}) async {
    List<Question> questionList = [];

    try {
      // First get last completed question from user's `BOOKS` collection
      UserBook _userBook = optionalLoadedUserBook ?? UserBook.fromSnap(await currentUser.snap.reference.collection('BOOKS').document(bookId).get());

      // Now check if exists
      if (_userBook != null && _userBook.lastCompletedQuestion != null) {
        // Check if last completed question exists
        if (_userBook.lastCompletedQuestion.path.isNotEmpty) {
          DocumentSnapshot lastCompletedQuestionSnap = await _userBook.lastCompletedQuestion.get();
          // Get all not completed questions based on last question

          QuerySnapshot allNotCompletedQuestions = await booksRef
              .document(bookId)
              .collection('QUESTIONS')
              .startAfterDocument(lastCompletedQuestionSnap)
              .orderBy('createdAt')
              .limit(limit)
              .getDocuments();

          if (allNotCompletedQuestions.documents.isNotEmpty) {
            allNotCompletedQuestions.documents.forEach((_doc) {
              questionList.add(Question.fromSnap(_doc));
            });
          }

          bookDebug('firestore_utils.dart', 'getNotCompletedQuestions', 'INFO',
              'Loaded ${questionList.length} NOT completed questions.');

        } else {
          // If doesn't exists then get all questions
          QuerySnapshot allNotCompletedQuestions = await booksRef
              .document(bookId)
              .collection('QUESTIONS')
              .orderBy('createdAt', descending: false)
              .limit(limit)
              .getDocuments();

          if (allNotCompletedQuestions.documents.isNotEmpty) {
            allNotCompletedQuestions.documents.forEach((_doc) {
              questionList.add(Question.fromSnap(_doc));
            });
          }
        }
      } else {
        // Create book under user's profile
        QuerySnapshot allNotCompletedQuestions = await booksRef
            .document(bookId)
            .collection('QUESTIONS')
            .orderBy('createdAt', descending: false)
            .limit(limit)
            .getDocuments();

        if (allNotCompletedQuestions.documents.isNotEmpty) {
          allNotCompletedQuestions.documents.forEach((_doc) {
            questionList.add(Question.fromSnap(_doc));
          });
        }

      }

      bookDebug('firestore_utils.dart', 'getNotCompletedQuestions', 'INFO', 'Loaded ${questionList.length} not completed questions.');

      return questionList;
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getNotCompletedQuestions', 'ERROR', e.toString());
    }
  }

  Future<int> getMyInProgressQuestionsLength(String bookId) async {
    try {
      UserBook _book = UserBook.fromSnap(await booksRef.document(bookId).get());

      var _myBookQuiz =
          await currentUser.snap.reference.collection('QUESTIONS').document(bookId).get();

      return _book.questionsLength - _myBookQuiz.data['questionsCompleted'];
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getNotCompletedQuestionsLength', 'ERROR', e.toString());
    }
  }

  Future<int> getMyCompletedQuestionsLength(String bookId) async {
    try {
      DocumentSnapshot myBookSnap =
          await currentUser.snap.reference.collection('BOOKS').document(bookId).get();

      UserBook updatedBook = UserBook.fromSnap(await booksRef.reference().document(bookId).get());
      // The difference is the amount of questions left;
      // Null means there are no MF QUESTIONS HOORAY;

      if (updatedBook != null && myBookSnap.exists && myBookSnap.data != null) {
        return updatedBook.questionsLength - myBookSnap.data['questionsCompleted'];
      } else {
        return null;
      }
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getMyCompletedQuestionsLength', 'ERROR', e.toString());
    }
  }

  Future<List<UserBook>> getMyInProgressBooks(int limit, {DocumentSnapshot startAfterDoc}) async {
    try {
      QuerySnapshot booksInProgressSnap;
      List<UserBook> listOfCompletedBooks = [];
      
      if (startAfterDoc != null){
        booksInProgressSnap = await currentUser.snap.reference
            .collection('BOOKS')
            .where('completed', isEqualTo: false)
            .startAfterDocument(startAfterDoc)
            .limit(limit)
            .getDocuments();
      } else {
        booksInProgressSnap = await currentUser.snap.reference
            .collection('BOOKS')
            .where('completed', isEqualTo: false)
            .limit(limit)
            .getDocuments();
      }

      if (booksInProgressSnap != null && booksInProgressSnap.documents.isNotEmpty) {
        booksInProgressSnap.documents.forEach((_doc) {
          listOfCompletedBooks.add(UserBook.fromSnap(_doc));
        });
      }

      return listOfCompletedBooks;
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getMyInProgressBooks', 'ERROR', e.toString());
    }
  }

  Future<List<UserBook>> getMyCompletedBooks(int limit, {DocumentSnapshot startAfterDoc}) async {
    try {
      QuerySnapshot completedBooksSnap;
      List<UserBook> listOfCompletedBooks = [];

      if (startAfterDoc != null){
        completedBooksSnap = await currentUser.snap.reference
            .collection('BOOKS')
            .where('completed', isEqualTo: true)
            .orderBy('completedAt', descending: true)
            .startAfterDocument(startAfterDoc)
            .limit(limit)
            .getDocuments();
      } else {
        completedBooksSnap = await currentUser.snap.reference
            .collection('BOOKS')
            .where('completed', isEqualTo: true)
            .orderBy('completedAt', descending: true)
            .limit(limit)
            .getDocuments();
      }

      if (completedBooksSnap != null && completedBooksSnap.documents.isNotEmpty) {
        completedBooksSnap.documents.forEach((_doc) {
          listOfCompletedBooks.add(UserBook.fromSnap(_doc));
        });
      }

      return listOfCompletedBooks;
    } catch (e) {
      bookDebug('firestore_utils.dart', 'getMyCompletedBooks', 'ERROR', e.toString());
    }
  }
}
