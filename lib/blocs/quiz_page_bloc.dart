import 'package:booquiz/models/Book.dart';
import 'package:booquiz/models/Question.dart';
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
  final List<Question> mList;
  final Book book;
  final int limit;

  QuizPageLoadQuestionsEvent(this.mList, this.book, this.limit);

  @override
  List<Object> get props => [mList, book, limit];
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

  @override
  List<Object> get props => [];

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

class QuizPageBloc extends Bloc<QuizPageEvents, QuizPageStates>{
  QuizPageBloc(): super(QuizPageEmptyState());

  @override
  Stream<QuizPageStates> mapEventToState(QuizPageEvents event) async* {

    if (event is QuizPageLoadQuestionsEvent){

      // Last not completed question is always loaded on BOOK page so skip it

    }

  }

}