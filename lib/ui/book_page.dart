import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/models/Book.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/ui/add_question_page.dart';
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

class _BookPageState extends State<BookPage> with TickerProviderStateMixin {
  Color mDeepOrange = Colors.deepOrange.shade100;
  Color mOrange = Colors.orange.shade50;
  Color mYellow = Colors.yellow.shade100;

  int currentTabPos = 0;
  TabController tabController; // Description, Quiz

  List<Question> questions = [];

  @override
  void initState() {
    super.initState();

    // Init shit
    tabController = TabController(length: 2, vsync: this);

    bookPageBloc.add(BookPageCheckQuestionsEvent(widget.book));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BlocBuilder(
        bloc: bookPageBloc,
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.deepOrangeAccent.shade100,
                  Colors.amber.shade100,
                ])),
            child: Stack(
              alignment: Alignment.topCenter,
//          fit: StackFit.expand,
              children: <Widget>[
                AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    margin: EdgeInsets.only(left: mainPadding),
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: BackButton(
                        color: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  title: Text(state is BookPageLoadedState
                      ? state.updatedBook.questionsLength == 1
                          ? state.updatedBook.questionsLength.toString() + ' question'
                          : state.updatedBook.questionsLength.toString() + ' questions'
                      : state is BookPageLoadingState ? '' :
                  questions.length == 1
                          ? '${questions.length} question'
                          : '${questions.length} questions'),
                  centerTitle: true,
                  actions: <Widget>[
                    Tooltip(
                      message: 'Add a question',
                      child: Container(
                        padding: EdgeInsets.only(right: dimensions.dim6()),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => AddQuestionPage(widget.book)))
                                .then((question) {
                              if (question != null) {
                                questions.add(question);
                                setState(() {});
                              }
                            });
                          },
                          icon: Icon(Icons.add, size: dimensions.dim30()),
                        ),
                      ),
                    )
                  ],
                ),

                // Main shit (Book, Title, Authors, Description)
                Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: dimensions.dim170()),
                      width: MediaQuery.of(context).size.width - dimensions.dim40(),
                      height: MediaQuery.of(context).size.height / 1.5,
                      decoration: ShapeDecoration(
                          color: Colors.orange.shade100,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
                    ),

                    // Book Top Image
                    Positioned(
                      top: dimensions.dim25(),
                      child: Container(
//                  alignment: Alignment.topCenter,
                        width: dimensions.dim120(),
                        height: dimensions.dim160(),
                        decoration: ShapeDecoration(
                            color: Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
                        margin: EdgeInsets.only(top: dimensions.dim60()),
                        child: widget.book.imageUrl == null ||
                                widget.book.imageUrl != null && widget.book.imageUrl.isEmpty
                            ? Text(
                                'No\ncover',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: dimensions.sp16()),
                              )
                            : Container(
                                alignment: Alignment.bottomLeft,
                                width: dimensions.dim120(),
                                height: dimensions.dim160(),
                                decoration: ShapeDecoration(
                                    color: Colors.grey[400],
                                    shape: RoundedRectangleBorder(),
                                    shadows: [
                                      BoxShadow(
                                          offset: Offset(0, 1),
                                          color: Colors.black54,
                                          blurRadius: 10)
                                    ]),
                                child: CachedNetworkImage(
                                  imageUrl: widget.book.imageUrl,
                                  width: dimensions.dim140(),
                                  height: dimensions.dim180(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                      ),
                    ),

                    // Book content (Title, Category, Authors, Description)

                    Positioned(
                      top: dimensions.dim265(),
                      width: MediaQuery.of(context).size.width - dimensions.dim66(),
                      height: dimensions.dim336(),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            // Title
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - dimensions.dim52(),
                              padding: EdgeInsets.symmetric(horizontal: mainPadding),
                              child: Text(
                                widget.book.title,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: dimensions.sp20(),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Category
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width - dimensions.dim52(),
//                          padding: EdgeInsets.symmetric(horizontal: mainPadding),
                              child: Text(
                                widget.book.categories.join(', '),
                                style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: dimensions.sp12(),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Authors
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: dimensions.dim8()),
                              child: Text(
                                widget.book.authors.join(', '),
                                style: TextStyle(
                                    fontSize: dimensions.sp15(),
                                    color: loginTextColor.withOpacity(.5)),
                              ),
                            ),

                            // Description
                            Container(
                              margin: EdgeInsets.only(top: dimensions.dim24()),
                              padding: EdgeInsets.only(bottom: mainPadding),
                              alignment: Alignment.center,
                              child: Text(
                                widget.book.description,
                                style: TextStyle(
//                              color: Colors.grey[500],
                                  color: Colors.black45,
                                  fontSize: dimensions.sp14(),
                                ),
//                            textAlign: TextAlign.justify,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Start Quiz button
                Positioned(
                  bottom: mainPadding,
                  child: Container(
//            color: Colors.white.withOpacity(.3),
                    width: MediaQuery.of(context).size.width,
                    height: dimensions.dim40(),
                    padding:
                        EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 5),
                    margin: EdgeInsets.only(bottom: dimensions.dim4()),
                    child: MaterialButton(
                      elevation: 0,
                      height: dimensions.dim40(),
                      color: Colors.orange.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(mainPadding)),
                          side: BorderSide(color: Colors.white, width: 2)),
                      onPressed: () {},
                      child: Text(
                        'Start quiz',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: dimensions.sp16(),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
