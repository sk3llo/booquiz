import 'package:booquiz/models/Book.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

class BookWidget extends StatelessWidget {

  final Book book;
  final int questionsCompleted;
  final int questionsInProgress;
  final Function(Book) onBookTapped;

  BookWidget(this.book, {this.onBookTapped, this.questionsCompleted, this.questionsInProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimensions.dim60(),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(right: 16.0, left: 8),
          onTap: ()  {
            if (onBookTapped != null)
              onBookTapped(book);
            },
          leading: book.imageUrl == null || book.imageUrl != null && book.imageUrl.isEmpty ?
              Container(
                width: dimensions.dim40(),
                height: dimensions.dim50(),
                color: Colors.grey,
                alignment: Alignment.center,
                child: Text(
                  'No\ncover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: dimensions.sp12()
                  ),
                ),
              ) :
          CachedNetworkImage(
            imageUrl: book.imageUrl,
            width: dimensions.dim50(),
            height: dimensions.dim80(),
          ),
          title: Text(
            book?.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            book.authors.isEmpty ? 'Unknown' : book?.authors?.first?.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),


        ),
      ),
    );
  }

}
