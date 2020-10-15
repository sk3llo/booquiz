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

class BookPageNewQuestionAddedEvent extends BookPageEvents {
  final Book book;

  BookPageNewQuestionAddedEvent(this.book);

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
  final Book mainBook;
  final Book userBook;

  BookPageLoadedState(this.mainBook, this.userBook);

  @override
  List<Object> get props => [mainBook, userBook];
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

    if (event is BookPageNewQuestionAddedEvent) {

    }

    if (event is BookPageLoadDetailsEvent) {
      try {
        yield BookPageLoadingState();

        Book userBook; // Book under (USERS/$id/BOOKS/);
        Book mainBook; // Book under (BOOKS/$id);

        DocumentSnapshot _userBookSnap =
            await currentUser.snap.reference.collection('BOOKS').document(event.book.id).get();
        // Get main book to check if new questions appeared or if _userBookSnap is null
        DocumentSnapshot _mainBookSnap = await booksRef.document(event.book.id).get();

        // If user already has a book
        if (_userBookSnap.exists && _userBookSnap.data != null) {
          userBook = Book.fromSnap(_userBookSnap);
          mainBook = Book.fromSnap(_mainBookSnap);

          // Check if questions list changed
          if (userBook.questionsLength != mainBook.questionsLength){
            userBook.questionsLength = mainBook.questionsLength;
            await userBook.snap.reference.updateData({
              'questionsLength': mainBook.questionsLength
            });
          }

          // Now get answers for the last not completed question if exists
          List<Question> lastNotCompletedQuestion = await fUtils
              .getNotCompletedQuestions(mainBook.id, optionalLoadedUserBook: userBook, limit: 1);

          mainBook.quiz.addAll(lastNotCompletedQuestion);

          bookDebug('book_page_bloc.dart', 'event is BookPageLoadDetailsEvent', 'INFO',
              'Loaded ${mainBook.quiz.length} questions.');

          yield BookPageLoadedState(mainBook, userBook);
        } else if (_mainBookSnap.exists && _mainBookSnap.data != null) {
          mainBook = Book.fromSnap(_mainBookSnap);

          // Update user's book;
          await currentUser.snap.reference.collection('BOOKS').document(event.book.id).setData({
            'authors': mainBook.authors,
            'id': mainBook.id,
            'title': mainBook.title,
            'subtitle': mainBook.subtitle,
            'questionsLength': mainBook.questionsLength,
            'timesCompleted': 0,
            'updatedAt': Timestamp.now(),
            'imageUrl': mainBook.imageUrl,
            'description': mainBook.description,
            'rating': mainBook.rating,
            'categories': mainBook.categories,
            'ref': mainBook.snap.reference,
            'totalTimeTaken': 0,
            'questionsCompleted': 0,
            'completed': mainBook.questionsCompleted == mainBook.questionsLength,
          }, merge: true);

          _userBookSnap = await currentUser.snap.reference.collection('BOOKS').document(event.book.id).get();
          userBook = Book.fromSnap(_userBookSnap);

          bookDebug('book_page_bloc.dart', 'event is BookPageLoadDetailsEvent', 'INFO',
              'Loaded ${mainBook.questionsLength} questions.');
          yield BookPageLoadedState(userBook, mainBook);
        } else {
          bookDebug(
              'book_page_bloc.dart', 'event is BookPageLoadDetailsEvent', 'INFO', 'Book is not in Firebase and has no questions yet');
          yield BookPageEmptyState();
        }
      } catch (e) {
        bookDebug(
            'book_page_bloc.dart', 'event is BookPageLoadDetailsEvent', 'ERROR', e.toString());
      }
    }
  }
}
