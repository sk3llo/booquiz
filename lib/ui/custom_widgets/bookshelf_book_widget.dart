import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';

class BookshelfBookWidget extends StatelessWidget {

  final UserBook mainBook;
//  final Book myBook;
//  final int questionsCompleted;
//  final int questionsInProgress;
  final Function(UserBook) onBookTapped;

  BookshelfBookWidget({@required this.mainBook, this.onBookTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: dimensions.dim80(),
      height: dimensions.dim120(),
      child: Card(
        elevation: 0,
        color: Colors.white70,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(mainPadding)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: mainBook.imageUrl,
              fit: BoxFit.fill,
            ),

            // Gradient over image
//            Positioned(
//              bottom: 0.0,
//              child: Container(
//                width: dimensions.dim80(),
//                height: dimensions.dim120(),
//                decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        begin: Alignment.bottomCenter,
//                        end: Alignment.topCenter,
//                        colors: [
//                          Colors.black38,
//                          Colors.transparent,
//                          Colors.transparent,
//                          Colors.transparent,
//                        ]
//                    )
//                ),
//              ),
//            ),

            Positioned(
              bottom: mainPadding,
              child: Text(
                '${mainBook?.questionsCompleted ?? 0} / ${mainBook?.questionsLength ?? 0}',
                style: TextStyle(
                  fontSize: dimensions.sp18(),
                  color: Colors.orange.shade200,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        color: Colors.black,
                        blurRadius: 12
                    )
                  ]
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

}
