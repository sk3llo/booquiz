import 'package:booquiz/tools/globals.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class ProfilePageEvents extends Equatable {
  ProfilePageEvents([List props = const []]) : super();
}

class ProfilePageUpdateAboutMeEvent extends ProfilePageEvents {
  final String aboutMe;
  ProfilePageUpdateAboutMeEvent(this.aboutMe);

  @override
  List<Object> get props => [aboutMe];
}


/// STATES

@immutable
abstract class ProfilePageStates extends Equatable {
  ProfilePageStates([List props = const []]) : super();
}

class ProfilePageEmptyState extends ProfilePageStates {

  @override
  List<Object> get props => [];

}

class ProfilePageLoadingState extends ProfilePageStates {

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}

class ProfilePageLoadedState extends ProfilePageStates {

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}

class ProfilePageErrorState extends ProfilePageStates {

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;

}

/// BLOC

class ProfilePageBloc extends Bloc<ProfilePageEvents, ProfilePageStates>{
  ProfilePageBloc(): super(ProfilePageEmptyState());

  @override
  Stream<ProfilePageStates> mapEventToState(ProfilePageEvents event) async* {

    if (event is ProfilePageUpdateAboutMeEvent){
      yield ProfilePageLoadingState();

      try {
        // Update about me
        await currentUser.snap.reference.updateData({
          'aboutMe': event.aboutMe
        });
        currentUser.aboutMe = event.aboutMe;

        yield ProfilePageLoadedState();
      } catch (e) {
        bookDebug('profile_page_bloc.dart', 'event is ProfilePageUpdateAboutMeEvent', 'ERROR', e.toString());
        yield ProfilePageEmptyState();
      }


    }

  }

}