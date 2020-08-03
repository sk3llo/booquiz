import 'package:booquiz/models/Book.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class BookshelfPageEvents extends Equatable {
  BookshelfPageEvents([List props = const []]) : super();
}

class BookshelfPageLoadInProgressEvent extends BookshelfPageEvents {
  final List<Book> mList;
  final int limit;

  BookshelfPageLoadInProgressEvent(this.mList, {this.limit = 10});

  @override
  List<Object> get props => [mList, limit];
}

class BookshelfPageLoadCompletedEvent extends BookshelfPageEvents {
  final List<Book> mList;
  final int limit;

  BookshelfPageLoadCompletedEvent(this.mList, {this.limit = 10});

  @override
  List<Object> get props => [mList, limit];
}


/// STATES

@immutable
abstract class BookshelfPageStates extends Equatable {
  BookshelfPageStates([List props = const []]) : super();
}

class BookshelfPageEmptyState extends BookshelfPageStates {

  @override
  List<Object> get props => [];

}

class BookshelfPageLoadingState extends BookshelfPageStates {
  final List<Book> mList;
  BookshelfPageLoadingState(this.mList);

  @override
  List<Object> get props => [mList];

  @override
  bool get stringify => true;

}

class BookshelfPageCompletedLoadedState extends BookshelfPageStates {
  final List<Book> mList;
  final bool noMoreItems;

  BookshelfPageCompletedLoadedState(this.mList, {this.noMoreItems = false});

  @override
  List<Object> get props => [mList, noMoreItems];

  @override
  bool get stringify => true;

}

class BookshelfPageInProgressLoadedState extends BookshelfPageStates {
  final List<Book> mList;
  final bool noMoreItems;

  BookshelfPageInProgressLoadedState(this.mList, {this.noMoreItems = false});

  @override
  List<Object> get props => [mList, noMoreItems];

  @override
  bool get stringify => true;

}

class BookshelfPageErrorState extends BookshelfPageStates {

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}

/// BLOC

class BookshelfPageBloc extends Bloc<BookshelfPageEvents, BookshelfPageStates>{
  BookshelfPageBloc(): super(BookshelfPageEmptyState());

  @override
  Stream<BookshelfPageStates> mapEventToState(BookshelfPageEvents event) async* {
    
    if (event is BookshelfPageLoadInProgressEvent){
      yield BookshelfPageLoadingState(event.mList);

      try {

        List<Book> _inProgressBooks = [];

        if (event.mList.isNotEmpty){
          _inProgressBooks = await fUtils.getMyInProgressBooks(event.limit, startAfterDoc: event.mList.last.snap);
        } else {
          _inProgressBooks = await fUtils.getMyInProgressBooks(event.limit);
        }

        event.mList.addAll(_inProgressBooks);

        // If empty then push `noMore`
        if (_inProgressBooks.isEmpty){
          yield BookshelfPageInProgressLoadedState(event.mList, noMoreItems: true);
        } else {
          yield BookshelfPageInProgressLoadedState(event.mList);
        }

      } catch (e) {
        bookDebug('bookshelf_page_bloc.dart', 'event is BookshelfPageLoadInProgressEvent', 'ERROR', e.toString());
        yield BookshelfPageErrorState();
      }

    }


    if (event is BookshelfPageLoadCompletedEvent){

      yield BookshelfPageLoadingState(event.mList);

      try {

        List<Book> _completedBooks = [];

        if (event.mList.isNotEmpty){
          _completedBooks = await fUtils.getMyInProgressBooks(event.limit, startAfterDoc: event.mList.last.snap);
        } else {
          _completedBooks = await fUtils.getMyInProgressBooks(event.limit);
        }

        event.mList.addAll(_completedBooks);

        // If empty then push `noMore`
        if (_completedBooks.isEmpty){
          yield BookshelfPageCompletedLoadedState(event.mList, noMoreItems: true);
        } else {
          yield BookshelfPageCompletedLoadedState(event.mList);
        }

      } catch (e) {
        bookDebug('bookshelf_page_bloc.dart', 'event is BookshelfPageLoadInProgressEvent', 'ERROR', e.toString());
        yield BookshelfPageErrorState();
      }

    }
    
  }

}