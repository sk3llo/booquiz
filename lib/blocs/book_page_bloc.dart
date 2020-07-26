import 'package:booquiz/models/Book.dart';
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

class BookPageCheckQuestionsEvent extends BookPageEvents {
  final Book book;
  BookPageCheckQuestionsEvent(this.book);

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

class BookPageBloc extends Bloc<BookPageEvents, BookPageStates>{
  BookPageBloc() : super(BookPageEmptyState());

  @override
  Stream<BookPageStates> mapEventToState(BookPageEvents event) async* {

    if (event is BookPageCheckQuestionsEvent){
      try {

        yield BookPageLoadingState();

        Book bookModel;

        var bookDoc = await booksRef.document(event.book.id).get();

        if (bookDoc.exists && bookDoc.data != null) {
          bookModel = Book.fromSnap(bookDoc);

          bookDebug('book_page_bloc.dart', 'event is BookPageCheckQuestionsEvent', 'INFO', 'Loaded ${bookModel.questionsLength} questions.');
          yield BookPageLoadedState(bookModel);
        } else {
          yield BookPageEmptyState();
        }

      } catch (e){
        bookDebug('book_page_bloc.dart', 'event is BookPageCheckQuestionsEvent', 'ERROR', e.toString());
      }
    }
  }

}