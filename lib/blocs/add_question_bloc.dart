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

        Timestamp _timestampNow = Timestamp.now();
        // Add question mark if doesn't exist
        String question = event.question.contains('?') ? event.question : event.question + '?';
        // This one needed to break down question for better search
        List<String> questionSearch =
            await fUtils.generateDisplayNameAndUsername(question.toLowerCase());
        String ansr1 = event.answer1 == '' ? 'Yes' : event.answer1;
        String ansr2 = event.answer2 == '' ? 'No' : event.answer2;

        List<String> answers = event.answer3 == null
            ? [ansr1, ansr2]
            : event.answer4 != null
                ? [ansr1, ansr2, event.answer3, event.answer4]
                : [ansr1, ansr2, event.answer3];

        DocumentSnapshot _bookDoc = await booksRef.document(event.book.id).get();

        // Check book doc and create if doesn't exist
        if (!_bookDoc.exists) {
          await booksRef.document(event.book.id).setData({
            'authors': event.book.authors,
            'id': event.book.id,
            'title': event.book.title,
            'subtitle': event.book.subtitle,
            'questionsLength': 0,
            'updatedAt': _timestampNow,
            'imageUrl': event.book.imageUrl,
            'description': event.book.description,
            'rating': event.book.rating,
            'starred': event.book.starred,
            'categories': event.book.categories
          });
          _bookDoc = await booksRef.document(event.book.id).get();
        }

        // Add a question


        // Create empty doc to get ID
        var _newQuestion = _bookDoc.reference.collection('QUESTIONS').document();
        // Add question to book
        await _newQuestion.setData({
          'answers': answers,
          'author': currentUser.snap.reference,
          'correctAnswer': event.correctAnswer,
          'createdAt': _timestampNow,
          'question': question,
          'questionSearch': questionSearch,
          'bookRef': booksRef.document(event.book.id),
          'id': _newQuestion.documentID
        });

        // Update book's `updatedAt`
        await _bookDoc.reference.updateData(
            {'updatedAt': _timestampNow, 'questionsLength': _bookDoc.data['questionsLength'] + 1});

        // Update current user's `questionCount`
        await currentUser.snap.reference
            .updateData({'questionsCount': currentUser.questionsCount + 1});

        // Add question ref to user's 'QUESTION' collection
        // But first check if it exists
        var _userQuestion = await currentUser.snap.reference
            .collection('QUESTIONS')
            .where('question', isEqualTo: question)
            .where('bookRef', isEqualTo: _bookDoc.reference)
            .getDocuments();

        if (_userQuestion != null && _userQuestion.documents != null && _userQuestion.documents.isNotEmpty){
          bookDebug('add_question_bloc.dart', 'event is AddQuestionEvent', 'INFO', 'Trying to add question that already exists.');
//          yield AddQuestionErrorState('Question already exists.');
        } else {
          // Add question to user
          await currentUser.snap.reference.collection('QUESTIONS').add({
            'ref': _newQuestion,
            'id': _newQuestion.documentID,
            'answers': answers,
            'correctAnswer': event.correctAnswer,
            'createdAt': _timestampNow,
            'question': event.question.contains('?') ? event.question : event.question + '?',
            'questionSearch': questionSearch,
            'bookRef': booksRef.document(event.book.id)
          });
        }

        bookDebug('add_question_bloc.dart', 'event is AddQuestionEvent', 'INFO', 'Successfully added question.');
        yield AddQuestionLoadedState(Question(event.question, questionSearch, event.correctAnswer,
            currentUser.snap.reference, answers, _timestampNow));
        yield AddQuestionEmptyState();
      } catch (e) {
        bookDebug('add_question_bloc.dart', 'event is AddQuestionEvent', 'ERROR', e.toString());
        yield AddQuestionErrorState();
      }
    }
  }
}
