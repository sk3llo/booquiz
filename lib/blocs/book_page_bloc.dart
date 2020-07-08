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

class _mEvent extends BookPageEvents {

  @override
  List<Object> get props => [];
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

  @override
  List<Object> get props => [];

}

class BookPageErrorState extends BookPageStates {

  @override
  List<Object> get props => [];

}

/// BLOC

class BookPageBloc extends Bloc<BookPageEvents, BookPageStates>{
  @override
  BookPageStates get initialState => BookPageEmptyState();

  @override
  Stream<BookPageStates> mapEventToState(BookPageEvents event) async* {

  }

}