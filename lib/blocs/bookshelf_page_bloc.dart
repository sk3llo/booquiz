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

class _mEvent extends BookshelfPageEvents {

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}

class BookshelfPageLoadedState extends BookshelfPageStates {

  @override
  List<Object> get props => [];

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



  }

}