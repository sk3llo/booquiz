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
abstract class AddQuestionEvents extends Equatable {
  AddQuestionEvents([List props = const []]) : super();
}

class AddQuestionEvent extends AddQuestionEvents {
  final Book book;
  final String question, correctAnswer, answer1, answer2, answer3, answer4;

  AddQuestionEvent(this.book, this.question, this.correctAnswer, this.answer1, this.answer2,
      {this.answer3, this.answer4});

  @override
  List<Object> get props => [book, question, correctAnswer, answer1, answer2, answer3, answer4];
}

/// STATES

@immutable
abstract class AddQuestionStates extends Equatable {
  AddQuestionStates([List props = const []]) : super();
}

class AddQuestionEmptyState extends AddQuestionStates {
  @override
  List<Object> get props => [];
}

class AddQuestionLoadingState extends AddQuestionStates {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class AddQuestionLoadedState extends AddQuestionStates {
  final Question question;

  AddQuestionLoadedState(this.question);

  @override
  List<Object> get props => [question];

  @override
  bool get stringify => true;
}

class AddQuestionErrorState extends AddQuestionStates {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

/// BLOC

class AddQuestionBloc extends Bloc<AddQuestionEvents, AddQuestionStates> {
  AddQuestionBloc() : super(AddQuestionEmptyState());

  @override
  Stream<AddQuestionStates> mapEventToState(AddQuestionEvents event) async* {
    if (event is AddQuestionEvent) {

      try {
        yield AddQuestionLoadingState();

        List<String> questionSearch = await fUtils.generateDisplayNameAndUsername(event.question.toLowerCase());
        Timestamp _timestampNow = Timestamp.now();
        String ansr1 = event.answer1 == '' ? 'Yes' : event.answer1;
        String ansr2 = event.answer2 == '' ? 'No' : event.answer2;

        CollectionReference booksRef = firestore.collection('BOOKS');
        List<String> answers = event.answer3 == null
            ? [ansr1, ansr2]
            : event.answer4 != null
            ? [ansr1, ansr2, event.answer3, event.answer4]
            : [ansr1, ansr2, event.answer3];

        DocumentSnapshot _doc = await booksRef.document(event.book.id).get();

        // Check doc and create if doesn't exist
        if (!_doc.exists) {
          await booksRef.document(event.book.id).setData({
            'author': event.book.authors,
            'id': event.book.id,
            'title': event.book.title,
            'questionsLength': 0,
            'updatedAt': _timestampNow,
          });
          _doc = await booksRef.document(event.book.id).get();
        }

        // Add a question
        await _doc.reference.collection('QUESTIONS').add({
          'answers': answers,
          'author': currentUser.snap.reference,
          'correctAnswer': event.correctAnswer,
          'createdAt': _timestampNow,
          'question': event.question.contains('?') ? event.question : event.question + '?',
          'questionSearch': questionSearch
        });

        // Update main Book doc
        await _doc.reference.updateData({
          'updatedAt': _timestampNow,
          'questionsLength': _doc.data['questionsLength'] + 1
        });

        yield AddQuestionLoadedState(Question(
            event.question,
            questionSearch,
            event.correctAnswer,
            currentUser.snap.reference,
            answers,
            _timestampNow
        ));
        yield AddQuestionEmptyState();
      } catch (e) {
        bookDebug('add_question_bloc.dart', 'event is AddQuestionEvent', 'ERROR', e.toString());
        yield AddQuestionErrorState();
      }

    }
  }
}
