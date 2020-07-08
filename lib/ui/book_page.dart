import 'package:booquiz/models/Book.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookPage extends StatefulWidget {
  final Book book;

  BookPage(this.book);

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    Color mDeepOrange = Colors.deepOrange.shade100;
    Color mOrange = Colors.orange.shade50;
    Color mYellow = Colors.yellow.shade100;

    return Scaffold(
//      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.grey,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.orange.shade100,
      body: BlocBuilder(
        bloc: bookPageBloc,
        builder: (context, state) {

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    // Image
                    Container(
                      width: dimensions.dim140(),
                      height: dimensions.dim180(),
                      margin: EdgeInsets.only(left: dimensions.dim16()),
                      color: Colors.grey,
                      child: widget.book.imageUrl == null ||
                          widget.book.imageUrl != null && widget.book.imageUrl.isEmpty
                          ? Text(
                        'No\ncover',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: dimensions.sp16()),
                      )
                          : CachedNetworkImage(
                        imageUrl: widget.book.imageUrl,
                        width: dimensions.dim140(),
                        height: dimensions.dim180(),
                        fit: BoxFit.fill,
                      ),
                    ),

                    // Book category / title / author
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: dimensions.dim16()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          // Category
                          widget.book.categories == null ||
                              widget.book.categories != null && widget.book.categories.isEmpty ?
                          Container()
                              :
                          Text(
                            widget.book.categories.first.toString(),
                            style: TextStyle(
                                color: colorBlueDarkText.withOpacity(.2),
                                fontSize: dimensions.dim16(),
                            ),
                          ),

                          // Title
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(top: dimensions.dim10(), bottom: dimensions.dim10()),
                            width: dimensions.dim200(),
                            child: Text(
                              widget.book.title,
                              style: TextStyle(
                                  color: colorBlueDarkText,
                                  fontSize: dimensions.dim18(),
                                  fontWeight: FontWeight.bold,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Author
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(top: dimensions.dim6(), bottom: dimensions.dim6()),
                            width: dimensions.dim200(),
                            child: Text(
                              widget.book.authors == null ||
                              widget.book.authors != null && widget.book.authors.isEmpty ?
                                  ''
                                  :
                              'by ' + widget.book.authors.join(',')

                              ,
                              style: TextStyle(
                                color: colorBlueDarkText.withOpacity(.3),
                                fontSize: dimensions.dim15(),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        ],

                      ),
                    )

                  ],
                ),
              ),
            ],
          );

        },
      ),
    );
  }


}
