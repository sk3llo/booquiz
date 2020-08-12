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

class QuizPageLoadQuestionsEvent extends QuizPageEvents {
  final Book book;
  final int limit;

  QuizPageLoadQuestionsEvent(this.book, this.limit);

  @override
  List<Object> get props => [book, limit];
}

class QuizPageCompleteQuestionEvent extends QuizPageEvents {
  final Book book;
  final Question question;
  final int timeTaken;

  QuizPageCompleteQuestionEvent(this.book, this.question, this.timeTaken);

  @override
  List<Object> get props => [book, question, timeTaken];
}

/// STATES

@immutable
abstract class QuizPageStates extends Equatable {
  QuizPageStates([List props = const []]) : super();
}

class QuizPageEmptyState extends QuizPageStates {
  @override
  List<Object> get props => [];
}

class QuizPageLoadingState extends QuizPageStates {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class QuizPageLoadedState extends QuizPageStates {
  final Book book;

  QuizPageLoadedState(this.book);

  @override
  List<Object> get props => [book];

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
    if (event is QuizPageLoadQuestionsEvent) {
      try {
        yield QuizPageLoadingState();

        List<Question> _listOfAllQuiz = [];

        // Get not completed questions
        _listOfAllQuiz = await fUtils
            .getNotCompletedQuestions(event.book.id, optionalLoadedUserBook: event.book, limit: event.limit);


        if (_listOfAllQuiz.isNotEmpty) {

          // Check for the last not completed question to remove it
          _listOfAllQuiz.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          List<Question> _listToAppend = [];
          _listOfAllQuiz.forEach((_newQ) {
            event.book.quiz.forEach((_oldQ) {
              if (_oldQ.question != _newQ.question && _oldQ.createdAt != _newQ.createdAt){
                _listToAppend.add(_newQ);
              }
            });
          });

          event.book.quiz.addAll(_listToAppend);
          event.book.quiz.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          bookDebug(
              'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'INFO', 'Loaded ${event.book.quiz.length} questions ');

          yield QuizPageLoadedState(event.book);
        } else {
          yield QuizPageEmptyState();
        }
      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageLoadQuestionsEvent', 'ERROR', e.toString());
      }
    }


    if (event is QuizPageCompleteQuestionEvent){

      try {
        yield QuizPageLoadingState();
        event.question.timeTaken = event.timeTaken;
        event.book.questionsCompleted += 1;
        event.book.questionsInProgress -= 1;


        // Update user's book ('questionsCompleted', 'completed');
        await currentUser.snap.reference.collection('BOOKS').document(event.book.id).setData({
          'questionsCompleted': event.book.questionsCompleted,
          'lastCompletedQuestion': event.question.snap.reference,
          'completed': event.book.questionsCompleted == event.book.questionsLength,
          'totalTimeTake': event.timeTaken
        }, merge: true);

        // Check if user already completed the same questions and if so update [timesCompleted]
        if (event.book.timesCompleted == null || event.book.timesCompleted != null && event.book.timesCompleted <= 0){
          await event.book.ref.collection('COMPLETED_BY').document(currentUser.snap.documentID).setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': 1,
            'userRef': currentUser.snap.reference,
            'when': Timestamp.now()
          }, merge: true);
        } else {
          await event.book.ref.collection('COMPLETED_BY').document(currentUser.snap.documentID).setData({
            'timeTaken': event.timeTaken,
            'timesCompleted': event.book.timesCompleted + 1,
            'when': Timestamp.now()
          }, merge: true);
        }

        // Add new completed question under book's 'COMPLETED_QUIZ';
        await currentUser.snap.reference.collection('BOOKS').document(event.book.id).setData({
          'questionsCompleted': event.book.questionsCompleted,
          'lastCompletedQuestion': event.question.snap.reference,
          'completed': event.book.questionsCompleted == event.book.questionsLength,
          'totalTimeTake': event.timeTaken
        }, merge: true);

        // Add new completed question under user book's 'COMPLETED_QUIZ';
        await currentUser.snap.reference.collection('BOOKS').document(event.book.id).collection('COMPLETED_QUIZ').add({
          'answered': event.question.answered,
          'answers': event.question.answers,
          'author': event.question.author,
          'completedAt': event.question.completedAt,
          'correctAnswer': event.question.correctAnswer,
          'question': event.question.question,
          'questionSearch': event.question.questionSearch,
          'timeTaken': event.question.timeTaken,
          'timesCompleted': event.question.timesCompleted,
        });

        // When completed all questions
        if (event.book.questionsCompleted == event.book.questionsLength){
          event.book.timesCompleted ??= 0;
          event.book.timesCompleted += 1;
          event.book.totalTimeTaken = event.timeTaken;

          // Update user's book doc
          await currentUser.snap.reference.collection('BOOKS').document(event.book.id).updateData({
            'timesCompleted': event.book.timesCompleted,
            'totalTimeTaken': event.timeTaken
          });

          // Update main book doc
          await event.book.ref.setData({
            'timesCompleted': event.book.timesCompleted,
            'totalTimeTaken': event.timeTaken
          }, merge: true);
        }
        
        yield QuizPageLoadedState(event.book);

      } catch (e) {
        bookDebug(
            'quiz_page_bloc.dart', 'event is QuizPageCompleteQuestionEvent', 'ERROR', e.toString());
      }

    }
  }
}
