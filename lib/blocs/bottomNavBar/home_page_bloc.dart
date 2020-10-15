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
abstract class HomePageBlocEvents extends Equatable {
  HomePageBlocEvents([List props = const []]) : super();
}

class HomePageSearchByGenreEvent extends HomePageBlocEvents {
  final String genreName;
  HomePageSearchByGenreEvent(this.genreName);

  @override
  List<Object> get props => [genreName];

}

class HomePageSearchByInputEvent extends HomePageBlocEvents {
  final String input;
  final int maxResults;
  final List<Book> mainList;

  HomePageSearchByInputEvent(this.input, {this.maxResults = 15, this.mainList = const []});

  @override
  List<Object> get props => [input, maxResults];

}

class HomePageGetRecentlyUpdatedBooksEvent extends HomePageBlocEvents {
  final int limit;
  HomePageGetRecentlyUpdatedBooksEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];

}


/// STATES

@immutable
abstract class HomePageBlocStates extends Equatable {
  HomePageBlocStates([List props = const []]) : super();
}

class HomePageBlocEmptyState extends HomePageBlocStates {

  @override
  List<Object> get props => [];

}

class HomePageBlocLoadingState extends HomePageBlocStates {
  final bool bottomIndicator;
  HomePageBlocLoadingState({this.bottomIndicator = false});

  @override
  List<Object> get props => [bottomIndicator];

}

class HomePageBlocLoadedState extends HomePageBlocStates {
  
  final List<Book> mainList;
  final bool noMoreItems;

  HomePageBlocLoadedState(this.mainList, {this.noMoreItems = false});

  @override
  List<Object> get props => [mainList];

}

class HomePageBlocErrorState extends HomePageBlocStates {

  @override
  List<Object> get props => [];

}

/// BLOC

class HomePageBloc extends Bloc<HomePageBlocEvents, HomePageBlocStates>{
  HomePageBloc() : super(HomePageBlocEmptyState());


  @override
  Stream<HomePageBlocStates> mapEventToState(HomePageBlocEvents event) async* {
    
    if (event is HomePageSearchByGenreEvent) {

      try {
        // Loading
        yield HomePageBlocLoadingState();

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
          categories: volumeInfo["categories"] ?? [],
          rating: volumeInfo["averageRating"] != null ? volumeInfo["averageRating"].toDouble() : 0.0
        );

        print(volumeInfo.length);
        print(book.title);
        print(book.imageUrl);
        print(book.authors);
        print(book.description);

      } catch (e) {
        bookDebug('home_page_bloc.dart', 'vent is HomePageSeachByInputEvent', 'ERROR', e.toString());
      }
    }

    if (event is HomePageSearchByInputEvent) {
      
      try {
        // Loading
        yield HomePageBlocLoadingState();
        
        Map<String, String> requestHeaders = {'Content-type': 'application/json','Accept': 'application/json'};

        // Replace whitespaces with +
        String _transformInput = event.input.trim().replaceAll(RegExp(r'\s'), '+').toLowerCase();

        var response = await http.get('https://www.googleapis.com/books/v1/volumes?q=$_transformInput&maxResults=${event.maxResults}&startIndex=${event.mainList.length}', headers: requestHeaders);

        dynamic items = jsonDecode(response.body)['items'];

        if (items == null){

          yield HomePageBlocLoadedState([]); // Empty result
          return;
        }

        bookDebug('home_page_bloc.dart', 'event is HomePageSeachByInputEvent', 'INFO', 'Loaded ${items.length} items. Total mList length is ${event.mainList.length}');

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
            categories: volumeInfo["categories"] ?? [],
            rating: volumeInfo["averageRating"] != null ? volumeInfo["averageRating"].toDouble() : 0.0
          );

          event.mainList.add(_book);
          
        }

        if (items.length < event.maxResults){
          // No more items
          yield HomePageBlocLoadedState(event.mainList, noMoreItems: true);
        } else {
          // Loaded state
          yield HomePageBlocLoadedState(event.mainList);
        }

      } catch (e) {
        bookDebug('home_page_bloc.dart', 'event is HomePageSeachByInputEvent', 'ERROR', e.toString());
      }

    }


  }

}