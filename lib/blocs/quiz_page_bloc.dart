import 'dart:math';

import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/main.dart';
import 'package:booquiz/models/MainBook.dart';
import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

/// EVENTS

@immutable
abstract class QuizPageEvents extends Equatable {
  QuizPageEvents([List props = const []]) : super();
}

class QuizPageLoadQuestionsEvent extends QuizPageEvents {
  final MainBook mainBook; // Quiz only in the main book
  final UserBook userBook; // All  [timesCompleted, timeTaken, lastQuestion] here
  final int limit;
  final AnimationController finishQuizAnimController;

  QuizPageLoadQuestionsEvent(
      this.mainBook, this.userBook, this.limit, this.finishQuizAnimController);

  @override
  List<Object> get props => [mainBook, userBook, limit, finishQuizAnimController];
}

class QuizPageNullStateEvent extends QuizPageEvents {
  @override
  List<Object> get props => [];
}

// Erase all book records from user and book
class QuizPageClearBookRecordEvent extends QuizPageEvents {
  final MainBook mainBook;
  final UserBook userBook;

  QuizPageClearBookRecordEvent(this.mainBook, this.userBook);

  @override
  List<Object> get props => [mainBook, userBook];
}

class QuizPageUpdateTotalTimeTakenEvent extends QuizPageEvents {
  final MainBook mainBook;
  final UserBook userBook;
  final int totalTimeTaken;

  QuizPageUpdateTotalTimeTakenEvent(this.mainBook, this.userBook, this.totalTimeTaken);

  @override
  List<Object> get props => [userBook, totalTimeTaken];
}

class QuizPageLoadResultEvent extends QuizPageEvents {
  final MainBook mainBook;
  final UserBook userBook;
  final int limit;
  final DocumentSnapshot startAfter;

  QuizPageLoadResultEvent(this.mainBook, this.userBook, {this.limit = 10, this.startAfter});

  @override
  List<Object> get props => [mainBook, userBook, limit, startAfter];
}

class QuizPageCompleteQuestionEvent extends QuizPageEvents {
  final MainBook mainBook;
  final UserBook userBook;
  final Question question;
  final int timeTaken;
  final AnimationController finishQuizAnimController;

  QuizPageCompleteQuestionEvent(
      this.mainBook, this.userBook, this.question, this.timeTaken, this.finishQuizAnimController);

  @override
  List<Object> get props => [mainBook, userBook, question, timeTaken, finishQuizAnimController];
}

/// STATES

@immutable
abstract class QuizPageStates extends Equatable {
  QuizPageStates([List props = const []]) : super();
}

class QuizPageEmptyState extends QuizPageStates {
  final MainBook mainBook;
  final UserBook userBook;

  QuizPageEmptyState({this.mainBook, this.userBook});

  @override
  List<Object> get props => [mainBook, userBook];
}

class QuizPageLoadingState extends QuizPageStates {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class QuizPageLoadedState extends QuizPageStates {
  final MainBook mainBook;
  final UserBook userBook;
  final Map<String, String> quote;
  final bool noMore;

  QuizPageLoadedState(this.mainBook, this.userBook, {this.quote, this.noMore = false});

  @override
  List<Object> get props => [mainBook, userBook, quote];

  @override
  bool get stringify => true;
}

class QuizPageErrorState extends QuizPageStates {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

/// BLOC

class QuizPageBloc extends Bloc<QuizPageEvents, QuizPageStates> {
  QuizPageBloc() : super(QuizPageEmptyState());

  Map<String, String> _quote;

  @override
  Stream<QuizPageStates> mapEventToState(QuizPageEvents event) async* {
    // Empty state
    if (event is QuizPageNullStateEvent) {
      yield QuizPageEmptyState();
    }

    if (event is QuizPageUpdateTotalTimeTakenEvent) {
      try {
        // Update total time taken when user leaves the screen
        await event.userBook.snap.reference.updateData({'totalTimeTaken': event.totalTimeTaken});

        bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'INFO',
            'Successfully updated totalTimeTaken from ${event.userBook.totalTimeTaken} to ${event.totalTimeTaken}');

        event.userBook.totalTimeTaken = event.totalTimeTaken;

        // Update states
        yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote);
        bookPageBloc.add(BookPageUpdateEvent(event.mainBook, event.userBook));


      } catch (e) {
        event.userBook.totalTimeTaken = event.totalTimeTaken;

        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'ERROR', e.toString());
      }
    }

    if (event is QuizPageLoadQuestionsEvent) {
      try {
        // yield QuizPageEmptyState();

        // Get not completed questions
        List<Question> _listOfAllQuiz = await fUtils.getNotCompletedQuestions(event.mainBook.id,
            optionalLoadedUserBook: event.userBook, limit: event.limit);

        if (_listOfAllQuiz != null) {
          if (_listOfAllQuiz.isNotEmpty) {
            // Check for the last not completed question to remove it
            _listOfAllQuiz.forEach((_newQ) {
              // Check if main quiz list already has question with the same documentID
              event.mainBook.quiz.firstWhere(
                  (_oldQ) => _newQ.snap.documentID == _oldQ.snap.documentID, orElse: () {
                // If not in the list add it
                if (_newQ.completedAt == null) {
                  event.mainBook.quiz.add(_newQ);
                }
                return;
              });
            });

            event.mainBook.quiz.sort((a, b) => a.createdAt.compareTo(b.createdAt));

            bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'INFO',
                'Loaded ${event.mainBook.quiz.length} questions');

            yield QuizPageLoadedState(event.mainBook, event.userBook);
          } else {
            // Load result questions until limit
            if (event.mainBook.completedQuiz.isEmpty)
              quizPageBloc.add(QuizPageLoadResultEvent(event.mainBook, event.userBook));
            // Most likely user has finished the quiz
            yield QuizPageLoadedState(event.mainBook, event.userBook);
            await event.finishQuizAnimController.forward();

            _quote = await getQuote();

            yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote);

            bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'INFO',
                'This quiz is finished');
          }
        } else {
          yield QuizPageEmptyState();
        }
      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'ERROR', e.toString());
      }
    }

    // Load results when quiz is done
    if (event is QuizPageLoadResultEvent) {
      try {
        QuerySnapshot _completedQuiz;

        // If has startAfter doc, startAfter: event.mainBook.completedQuiz.isNotEmpty ? event.mainBook.completedQuiz.last.snap : null
        if (event.startAfter != null) {
          _completedQuiz = await event.userBook.snap.reference
              .collection('COMPLETED_QUIZ')
              .orderBy('completedAt')
              .startAfterDocument(event.startAfter)
              .limit(event.limit)
              .getDocuments();
        } else {
          _completedQuiz = await event.userBook.snap.reference
              .collection('COMPLETED_QUIZ')
              .orderBy('completedAt')
              .limit(event.limit)
              .getDocuments();
        }

        if (_completedQuiz != null) {
          if (_completedQuiz.documents.isNotEmpty) {
            _completedQuiz.documents.forEach((d) {
              var _q = Question.fromSnap(d);

              if (event.mainBook.completedQuiz.isNotEmpty) {
                // Check if already contains question and if so just skip it
                event.mainBook.completedQuiz.firstWhere(
                    (_compQ) =>
                        _q.question == _compQ.question &&
                        _q.completedAt.millisecondsSinceEpoch ==
                            _compQ.completedAt.millisecondsSinceEpoch, orElse: () {
                  // If not in the list yet then just add it
                  event.mainBook.completedQuiz.add(_q);
                  return;
                });
              } else {
                event.mainBook.completedQuiz.add(_q);
                return;
              }
            });

            event.mainBook.completedQuiz.sort((a, b) => a.completedAt.compareTo(b.completedAt));

            yield QuizPageEmptyState(mainBook: event.mainBook, userBook: event.userBook);

            bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadResultEvent', 'INFO',
                'Loaded ${event.mainBook.completedQuiz.length} completed questions.');

            yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote);
          } else {
            yield QuizPageEmptyState(mainBook: event.mainBook, userBook: event.userBook);
            bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadResultEvent', 'INFO',
                'Loaded ${event.mainBook.completedQuiz.length} completed questions.\nNo more left');
            yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote, noMore: true);
          }
        } else {
          bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadResultEvent', 'ERROR',
              '_completedQuiz == null daaamn');
        }
      } catch (e) {
        bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadResultEvent', 'ERROR', e.toString());
      }
    }

    if (event is QuizPageCompleteQuestionEvent) {
      try {
        event.question.timeTaken = event.timeTaken;
        event.question.completedAt = Timestamp.now();
        event.question.timesCompleted = event.question.timesCompleted + 1;
        event.userBook.totalTimeTaken = event.timeTaken;
        event.userBook.questionsCompleted += 1;
        event.userBook.questionsInProgress -= 1;
        event.userBook.lastCompletedQuestion = event.question.snap.reference;
        // If completed all questions also update fields below
        if (event.userBook.questionsCompleted == event.mainBook.questionsLength) {
          event.mainBook.timesCompleted ??= 0;
          event.userBook.timesCompleted ??= 0;
          event.mainBook.timesCompleted += 1;
          event.userBook.timesCompleted += 1;
          event.userBook.completed = true;
          event.userBook.totalTimeTaken = event.timeTaken;
        }

        yield QuizPageEmptyState(mainBook: event.mainBook, userBook: event.userBook);

        // Update user's book;
        await event.userBook.snap.reference.setData({
          'timesCompleted': event.userBook.timesCompleted,
          'updatedAt': event.question.completedAt,
          'questionsLength': event.userBook.questionsLength,
          'questionsCompleted': event.userBook.questionsCompleted,
          'lastCompletedQuestion': event.question.snap.reference,
          'completed': event.userBook.questionsCompleted == event.mainBook.questionsLength,
          'totalTimeTaken': event.timeTaken
        }, merge: true);

        // Update books question [timesCompleted]
        await event.question.snap.reference
            .updateData({'timesCompleted': event.question.timesCompleted});

        // Check if user already completed question and if so update [timesCompleted, timeTaken, when]
        if (event.userBook.timesCompleted == null ||
            event.userBook.timesCompleted != null && event.userBook.timesCompleted == 0) {
          await event.question.snap.reference
              .collection('COMPLETED_BY')
              .document(currentUser.snap.documentID)
              .setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': 1,
            'userRef': currentUser.snap.reference,
            'userPath': currentUser.snap.reference.path,
            'when': event.question.completedAt
          }, merge: true);
        } else {
          await event.question.snap.reference
              .collection('COMPLETED_BY')
              .document(currentUser.snap.documentID)
              .setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': event.userBook.timesCompleted,
            'userRef': currentUser.snap.reference,
            'userPath': currentUser.snap.reference.path,
            'when': event.question.completedAt
          }, merge: true);
        }

        // Add new completed question under user book's 'COMPLETED_QUIZ';
        await event.userBook.snap.reference.collection('COMPLETED_QUIZ').add({
          'answered': event.question.answered,
          'answers': event.question.answers,
          'author': event.question.author,
          'completedAt': event.question.completedAt,
          'correctAnswer': event.question.correctAnswer,
          'question': event.question.question,
          'questionSearch': event.question.questionSearch,
          'timeTaken': event.question.timeTaken,
          'timesCompleted': event.userBook.timesCompleted ?? 1,
        });

        // When completed all questions
        if (event.userBook.completed == true) {
          // Load results
          quizPageBloc.add(QuizPageLoadResultEvent(event.mainBook, event.userBook));

          // Update user's book doc
          await event.userBook.snap.reference.updateData({
            'timesCompleted': event.userBook.timesCompleted,
            'totalTimeTaken': event.timeTaken,
            'lastCompletedQuestion': event.question.snap.reference
          });

          // Update main book doc
          await event.mainBook.snap.reference
              .setData({'timesCompleted': event.mainBook.timesCompleted}, merge: true);

          // Add doc to [COMPLETED_BY] under main book
          await event.mainBook.snap.reference
              .collection('COMPLETED_BY')
              .document(currentUser.snap.documentID)
              .setData({
            'timeTaken': event.timeTaken,
            'questionsCompleted': event.mainBook.questionsLength,
            'timesCompleted': event.userBook.timesCompleted,
            'userRef': currentUser.snap.reference,
            'userPath': currentUser.snap.reference.path,
            'when': event.question.completedAt
          }, merge: true);


          event.mainBook.quiz.remove(event.question);
          yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote);
          await event.finishQuizAnimController.forward();
          return;
        }

        event.mainBook.quiz.remove(event.question);

        yield QuizPageLoadedState(event.mainBook, event.userBook, quote: _quote);

        if (event.userBook.questionsCompleted - event.mainBook.questionsLength <= 3 &&
            _quote == null || _quote.isEmpty) {
          _quote = await getQuote();
        }
      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageCompleteQuestionEvent', 'ERROR', e.toString());
      }
    }

    // Erase all the book records
    if (event is QuizPageClearBookRecordEvent) {

      try {
        event.userBook.totalTimeTaken = 0;
        event.userBook.questionsInProgress = 0;
        event.userBook.questionsCompleted = 0;
        event.userBook.lastCompletedQuestion = null;
        // If completed all questions also update fields below
        event.mainBook.timesCompleted = 0;
        event.mainBook.quiz = [];
        event.mainBook.completedQuiz = [];
        event.mainBook.completedQuiz = [];
        event.userBook.timesCompleted = 0;
        event.userBook.completed = false;
        event.userBook.totalTimeTaken = null;

        _quote = {};

        // Reset main book doc
        await event.mainBook.snap.reference
            .updateData({'timesCompleted': 0});

        // Erase COMPLETED_BY in MAIN BOOK
        await event.mainBook.snap.reference
            .collection('COMPLETED_BY')
            .where('usePath', isEqualTo: currentUser.snap.reference.path)
            .getDocuments()
            .then((d) async {
          if (d != null && d.documents.isNotEmpty){
            await d.documents.first.reference.delete();
          }
        });

        // For each question in MAIN BOOK update data
        await event.mainBook.snap.reference
            .collection('QUESTIONS')
            .getDocuments()
            .then((_quiz) async {
          await Future.forEach<DocumentSnapshot>(_quiz.documents, (_q) async {
            await _q.reference.updateData({'timesCompleted': 0});
          });
        });

        // Erase COMPLETED_BY in each MAIN BOOK QUESTIONS
        await event.mainBook.snap.reference
            .collection('QUESTIONS')
            .getDocuments()
            .then((d) async {
          //.where('useRef', isEqualTo: currentUser.snap.reference.path)
          await Future.forEach<DocumentSnapshot>(d.documents, (_q) async {
            await _q.reference.collection('COMPLETED_BY')
                .where('usePath', isEqualTo: currentUser.snap.reference.path)
                .getDocuments()
                .then((d) async {
                  if (d != null && d.documents.isNotEmpty){
                    await d.documents.first.reference.delete();
                  }
            });
          });
        });


        // DELETE ALL COMPLETED QUIZ FROM USER'S BOOK
        await event.userBook.snap.reference.collection('COMPLETED_QUIZ').getDocuments().then((docs) async {
          if (docs != null && docs.documents.isNotEmpty) {
            await Future.forEach<DocumentSnapshot>(docs.documents, (_d) async {
              await _d.reference.delete();
            });
          }
        });

        // UPDATE USER'S BOOK
        await event.userBook.snap.reference.updateData({
          'totalTimeTaken': 0,
          'timesCompleted': 0,
          'questionsCompleted': 0,
          'completed': false,
          'lastCompletedQuestion': null
        });

        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageClearBookRecordEvent', 'INFO', 'Successfully erased book\'s records.');

        yield QuizPageEmptyState(mainBook: event.mainBook, userBook: event.userBook);

        bookPageBloc.add(BookPageUpdateEvent(event.mainBook, event.userBook));
        yield QuizPageLoadedState(event.mainBook, event.userBook);

      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageClearBookRecordEvent', 'ERROR', e.toString());
      }

    }
  }
}

Future<Map<String, String>> getQuote() async {
  try {
    int _page =
        Random.secure().nextInt(101) == 0 ? 1 : Random.secure().nextInt(101); // max 100 pages
    String _category = Random.secure().nextBool() ? 'books' : 'reading'; // random category

    // https://www.goodreads.com/quotes/tag/reading?page=100

    http.Response _response =
        await http.get('https://www.goodreads.com/quotes/tag/books?page=$_page');

    if (_response.statusCode == 200) {
      var _page = parser.parse(_response.body);

      var _quotes = _page.body.getElementsByClassName('quoteText');

      var _randomNum = Random.secure().nextInt(_quotes.length);
      String _randomQuote = _quotes[_randomNum].text.trim();

      var quoteAndAuthor = _randomQuote
          .replaceAll(RegExp(r'\n.'), '')
          .replaceAll(RegExp(r'\n.*'), ''); // convert string to list[quote, author]
      List<String> _quote = quoteAndAuthor.split('   ―    ');
      _quote.removeRange(1, _quote.length);

      String _author =
          quoteAndAuthor.replaceAll(RegExp(r'.*”   ―    '), '').replaceAll(RegExp(r',.*'), '');

      List<String> _fromWhere = quoteAndAuthor.split(',         ')
        ..removeAt(0); // from where the quote was taken (book/novel/story)

      Map<String, String> data = {
        'quote': _quote.first.trim(),
        'authors': _author
        // 'fromWhere': _fromWhere.first.trim()
      };

      return data;
    } else {
      return {'The unexamined life is not worth living.': 'Socrates'};
    }
  } catch (e) {
    bookDebug('quiz_page_bloc.dart', '_getQuote()', 'ERROR', e.toString());
  }
}
