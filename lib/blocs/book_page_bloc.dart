import 'package:booquiz/models/Book.dart';
import 'package:booquiz/models/Question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class BookPageEvents extends Equatable {
  BookPageEvents([List props = const []]) : super();
}

class BookPageLoadDetailsEvent extends BookPageEvents {
  final Book book;

  BookPageLoadDetailsEvent(this.book);

  @override
  List<Object> get props => [book];
}

/// STATES

@immutable
abstract class BookPageStates extends Equatable {
  BookPageStates([List props = const []]) : super();
}

class BookPageEmptyState extends BookPageStates {
  @override
  List<Object> get props => [];
}

class BookPageLoadingState extends BookPageStates {
  @override
  List<Object> get props => [];
}

class BookPageLoadedState extends BookPageStates {
  final Book updatedBook;

  BookPageLoadedState(this.updatedBook);

  @override
  List<Object> get props => [updatedBook];
}

class BookPageErrorState extends BookPageStates {
  @override
  List<Object> get props => [];
}

/// BLOC

class BookPageBloc extends Bloc<BookPageEvents, BookPageStates> {
  BookPageBloc() : super(BookPageEmptyState());

  @override
  Stream<BookPageStates> mapEventToState(BookPageEvents event) async* {
    if (event is BookPageLoadDetailsEvent) {
      try {
        yield BookPageLoadingState();

        Book bookToReturn; // The one to return;
        Book userBook; // Book under (USERS/$id/BOOKS/);
        Book mainBook; // Book under (BOOKS/$id);

        DocumentSnapshot _userBookSnap =
            await currentUser.snap.reference.collection('BOOKS').document(event.book.id).get();
        // Get main book to check if new questions appeared
        // or if _userBookSnap is null
        DocumentSnapshot _mainBookSnap = await booksRef.document(event.book.id).get();

        if (_userBookSnap.exists && _userBookSnap.data != null) {
          userBook = Book.fromSnap(_userBookSnap);
          mainBook = Book.fromSnap(_mainBookSnap);
          // Check if questions list changed
          if (userBook.questionsLength != mainBook.questionsLength)
            userBook.questionsLength = mainBook.questionsLength;

          // Now get answers for the last not completed question if exists
          List<Question> lastNotCompletedQuestion = await fUtils
              .getNotCompletedQuestions(userBook.id, optionalLoadedUserBook: userBook, limit: 1);

          userBook.quiz.addAll(lastNotCompletedQuestion);
          userBook.quiz.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          bookToReturn = userBook;
          yield BookPageLoadedState(bookToReturn);
        } else if (_mainBookSnap.exists && _mainBookSnap.data != null) {
          mainBook = Book.fromSnap(_mainBookSnap);
          bookToReturn = mainBook;
          bookDebug('book_page_bloc.dart', 'event is BookPageCheckQuestionsEvent', 'INFO',
              'Loaded ${bookToReturn.questionsLength} questions.');
          yield BookPageLoadedState(bookToReturn);
        } else {
          bookDebug(
              'book_page_bloc.dart', 'event is BookPageCheckQuestionsEvent', 'INFO', 'Book is not in db yet');
          yield BookPageEmptyState();
        }
      } catch (e) {
        bookDebug(
            'book_page_bloc.dart', 'event is BookPageCheckQuestionsEvent', 'ERROR', e.toString());
      }
    }
  }
}
