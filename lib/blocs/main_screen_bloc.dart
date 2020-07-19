import 'package:booquiz/models/Book.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// EVENTS

@immutable
abstract class MainScreenBlocEvents extends Equatable {
  MainScreenBlocEvents([List props = const []]) : super();
}

class MainScreenSearchByGenreEvent extends MainScreenBlocEvents {
  final String genreName;
  MainScreenSearchByGenreEvent(this.genreName);

  @override
  List<Object> get props => [genreName];

}

class MainScreenSearchByInputEvent extends MainScreenBlocEvents {
  final String input;
  final int maxResults;
  final List<Book> mainList;

  MainScreenSearchByInputEvent(this.input, {this.maxResults = 15, this.mainList = const []});

  @override
  List<Object> get props => [input, maxResults];

}

class MainScreenGetRecentlyUpdatedBooksEvent extends MainScreenBlocEvents {
  final int limit;
  MainScreenGetRecentlyUpdatedBooksEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];

}


/// STATES

@immutable
abstract class MainScreenBlocStates extends Equatable {
  MainScreenBlocStates([List props = const []]) : super();
}

class MainScreenBlocEmptyState extends MainScreenBlocStates {

  @override
  List<Object> get props => [];

}

class MainScreenBlocLoadingState extends MainScreenBlocStates {
  final bool bottomIndicator;
  MainScreenBlocLoadingState({this.bottomIndicator = false});

  @override
  List<Object> get props => [bottomIndicator];

}

class MainScreenBlocLoadedState extends MainScreenBlocStates {
  
  final List<Book> mainList;
  final bool noMoreItems;

  MainScreenBlocLoadedState(this.mainList, {this.noMoreItems = false});

  @override
  List<Object> get props => [mainList];

}

class MainScreenBlocErrorState extends MainScreenBlocStates {

  @override
  List<Object> get props => [];

}

/// BLOC

class MainScreenBloc extends Bloc<MainScreenBlocEvents, MainScreenBlocStates>{
  MainScreenBloc() : super(MainScreenBlocEmptyState());


  @override
  Stream<MainScreenBlocStates> mapEventToState(MainScreenBlocEvents event) async* {
    
    if (event is MainScreenSearchByGenreEvent) {

      try {
        // Loading
        yield MainScreenBlocLoadingState();

        var response = await http.get('https://www.googleapis.com/books/v1/volumes?q=subject:${event.genreName}');

        dynamic jsonBook = jsonDecode(response.body)['items'][0];

        var volumeInfo = jsonBook["volumeInfo"];

        Book book = Book(
          title: volumeInfo["title"].toString() ?? '',
          imageUrl: volumeInfo["imageLinks"] != null? volumeInfo["imageLinks"]["smallThumbnail"]: "",
          id: jsonBook["id"],
          //only first author
          authors: volumeInfo["authors"] ?? '',
          description: volumeInfo["description"] ?? '',
          subtitle: volumeInfo["subtitle"] ?? '',
          categories: volumeInfo["categories"] ?? []
        );

        print(volumeInfo.length);
        print(book.title);
        print(book.imageUrl);
        print(book.authors);
        print(book.description);

      } catch (e) {
        bookDebug('main_screen_bloc.dart', 'vent is MainScreenSeachByInputEvent', 'ERROR', e.toString());
      }
    }

    if (event is MainScreenSearchByInputEvent) {
      
      try {
        // Loading
        yield MainScreenBlocLoadingState();
        
        Map<String, String> requestHeaders = {'Content-type': 'application/json','Accept': 'application/json'};

        // Replace whitespaces with +
        String _transformInput = event.input.trim().replaceAll(RegExp(r'\s'), '+').toLowerCase();
        print(_transformInput);

        var response = await http.get('https://www.googleapis.com/books/v1/volumes?q=$_transformInput&maxResults=${event.maxResults}&startIndex=${event.mainList.length}', headers: requestHeaders);

        dynamic items = jsonDecode(response.body)['items'];

        if (items == null){

          yield MainScreenBlocLoadedState([]); // Empty result
          return;
        }

        bookDebug('main_screen_bloc.dart', 'event is MainScreenSeachByInputEvent', 'INFO', 'Loaded ${items.length} items. Total mList length is ${event.mainList.length}');

        for (var i in items){

          var volumeInfo = i["volumeInfo"];

          Book _book = Book(
            title: volumeInfo["title"].toString() ?? '',
            imageUrl: volumeInfo["imageLinks"] != null ? volumeInfo["imageLinks"]["smallThumbnail"]: "",
            id: i['id'], // jsonBook["id"],
            //only first author
            authors: volumeInfo["authors"] != null ? List.from(volumeInfo["authors"]) : [],
            description: volumeInfo["description"] ?? '',
            subtitle: volumeInfo["subtitle"] ?? '',
            categories: volumeInfo["categories"] ?? []
          );
          
          event.mainList.add(_book);
          
        }

        if (items.length < event.maxResults){
          // No more items
          yield MainScreenBlocLoadedState(event.mainList, noMoreItems: true);
        } else {
          // Loaded state
          yield MainScreenBlocLoadedState(event.mainList);
        }

      } catch (e) {
        bookDebug('main_screen_bloc.dart', 'event is MainScreenSeachByInputEvent', 'ERROR', e.toString());
      }

    }


  }

}