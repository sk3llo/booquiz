import 'package:booquiz/main.dart';
import 'package:booquiz/models/Book.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class QuizPageEvents extends Equatable {
  QuizPageEvents([List props = const []]) : super();
}

class QuizPageNullStateEvent extends QuizPageEvents {
  QuizPageNullStateEvent();

  @override
  List<Object> get props => [];
}

class QuizPageLoadQuestionsEvent extends QuizPageEvents {
  final Book mainBook; // Quiz only in the main book
  final Book userBook; // All  [timesCompleted, timeTaken, lastQuestion] here
  final int limit;

  QuizPageLoadQuestionsEvent(this.mainBook, this.userBook, this.limit);

  @override
  List<Object> get props => [mainBook, userBook, limit];
}

class QuizPageUpdateTotalTimeTakenEvent extends QuizPageEvents {
  final Book userBook;
  final int totalTimeTaken;

  QuizPageUpdateTotalTimeTakenEvent(this.userBook, this.totalTimeTaken);

  @override
  List<Object> get props => [userBook, totalTimeTaken];
}

class QuizPageCompleteQuestionEvent extends QuizPageEvents {
  final Book mainBook;
  final Book userBook;
  final Question question;
  final int timeTaken;

  QuizPageCompleteQuestionEvent(this.mainBook, this.userBook, this.question, this.timeTaken);

  @override
  List<Object> get props => [mainBook, userBook, question, timeTaken];
}

/// STATES

@immutable
abstract class QuizPageStates extends Equatable {
  QuizPageStates([List props = const []]) : super();
}

class QuizPageEmptyState extends QuizPageStates {
  final Book mainBook;
  final Book userBook;

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
  final Book mainBook;
  final Book userBook;

  QuizPageLoadedState(this.mainBook, this.userBook);

  @override
  List<Object> get props => [mainBook, userBook];

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

  @override
  Stream<QuizPageStates> mapEventToState(QuizPageEvents event) async* {
    if (event is QuizPageUpdateTotalTimeTakenEvent) {
      try {
        // Update total time taken when user leaves the screen
        await currentUser.snap.reference.updateData({'totalTimeTaken': event.totalTimeTaken});
        bookDebug('quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'INFO',
            'Successfully updated totalTimeTaken from ${event.userBook.totalTimeTaken} to ${event.totalTimeTaken}');

        event.userBook.totalTimeTaken = event.totalTimeTaken;
      } catch (e) {
        event.userBook.totalTimeTaken = event.totalTimeTaken;

        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'ERROR', e.toString());
      }
    }

    if (event is QuizPageLoadQuestionsEvent) {
      try {
//        if (event.mainBook.quiz.isEmpty)
//          yield QuizPageLoadingState();
//        else if (state is QuizPageLoadedState || state is QuizPageLoadingState || state is QuizPageErrorState)
//          yield QuizPageEmptyState(mainBook: event.mainBook, userBook: event.userBook);

        // Get not completed questions
        List<Question> _listOfAllQuiz = await fUtils.getNotCompletedQuestions(event.mainBook.id,
            optionalLoadedUserBook: event.userBook, limit: event.limit);

        // print(_listOfAllQuiz.length);

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
            yield QuizPageLoadedState(event.mainBook, event.userBook);
          }
        } else {
          yield QuizPageEmptyState(userBook: Book.createEmpty(), mainBook: Book.createEmpty());
        }
      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'ERROR', e.toString());
      }
    }

    if (event is QuizPageCompleteQuestionEvent) {
      try {
//        yield QuizPageLoadingState();

        event.question.timeTaken = event.timeTaken;
        event.question.completedAt = Timestamp.now();
        event.question.timesCompleted = event.question.timesCompleted + 1;
        event.mainBook.totalTimeTaken = event.timeTaken;
        event.userBook.totalTimeTaken = event.timeTaken;
        event.userBook.questionsCompleted += 1;
        event.userBook.questionsInProgress -= 1;
        event.userBook.lastCompletedQuestion = event.question.snap.reference;

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
            'when': event.question.completedAt
          }, merge: true);
        } else {
          await event.question.snap.reference
              .collection('COMPLETED_BY')
              .document(currentUser.snap.documentID)
              .setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': event.userBook.timesCompleted + 1,
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
          'timesCompleted':
              event.userBook.timesCompleted == null ? 0 : event.userBook.timesCompleted + 1,
        });

        // When completed all questions
        if (event.userBook.questionsCompleted == event.mainBook.questionsLength) {
          event.mainBook.timesCompleted ??= 0;
          event.userBook.timesCompleted ??= 0;
          event.userBook.timesCompleted += 1;
          event.mainBook.completed = true;
          event.userBook.completed = true;
          event.userBook.totalTimeTaken = event.timeTaken;

          // Update user's book doc
          await event.userBook.snap.reference.updateData({
            'timesCompleted': event.userBook.timesCompleted,
            'totalTimeTaken': event.timeTaken,
            'lastCompletedQuestion': event.question.snap.reference
          });

          // Update main book doc
          await event.mainBook.ref
              .setData({'timesCompleted': event.mainBook.timesCompleted}, merge: true);

          // Add doc to [COMPLETED_BY] under main book
          await event.mainBook.ref
              .collection('COMPLETED_BY')
              .document(currentUser.snap.documentID)
              .setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': event.userBook.timesCompleted,
            'userRef': currentUser.snap.reference,
            'when': event.question.completedAt
          }, merge: true);
        }

        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        // //   // Remove updated question from the list
        //   event.mainBook.quiz.remove(event.question);
        // });

        yield QuizPageLoadedState(event.mainBook, event.userBook);
      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageCompleteQuestionEvent', 'ERROR', e.toString());
      }
    }
  }
}
