import 'dart:async';
import 'dart:ui';

import 'package:booquiz/models/Book.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/ui/book_page.dart';
import 'package:booquiz/ui/custom_widgets/book_widget.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:booquiz/ui/login/login_step1.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/blocs/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:overlay_support/overlay_support.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController searchFieldController = TextEditingController();
  FocusNode searchFieldFocus = FocusNode();

  int bottonNavBarIndex = 0;

  // Search Books View defs
  bool searchBookView = false;
  String oldSearch = '';

  ScrollController searchBooksScrollController = ScrollController();

  List<Book> searchBooksList = [];

  @override
  void initState() {
    super.initState();

//    mainScreenBloc.add(GetBooksByCategory());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        setState(() {});
//        Navigator.of(context).push(MaterialPageRoute(
//          builder: (c) => LoginStep1()
//        ));
      },
      child: Scaffold(
        backgroundColor: Colors.orange.shade100,
        // Main Bloc Builder
        body: BlocBuilder(
          bloc: mainScreenBloc,
          builder: (context, state) {
            return Stack(
              children: <Widget>[
                // Main Content
                Container(
                  margin: EdgeInsets.only(top: dimensions.dim95()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Categories
                      topCategories(state),

                      // Recently updated
                      recentlyUpdated(state),

                      // Top Likes
                      topLikes(state),

                      // Top Questions
                      topQuestions(state),

                      // Top buttons
//                  topButtons(state),

//                  mainView(state),
                    ],
                  ),
                ),

                // Search books text field
                Positioned(
                  top: dimensions.dim35(),
                  child: BackdropFilter(
                    // Blur filter
                    filter: ImageFilter.blur(
                        sigmaX: searchFieldFocus.hasFocus ? 5 : 0,
                        sigmaY: searchFieldFocus.hasFocus ? 5 : 0),
                    child: Row(
                      children: <Widget>[
                        // Search field
                        searchBooksField(state),
                        // TEST BUTTON REMOVE AFTER
                        Container(
                          margin: EdgeInsets.only(left: mainPadding),
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                            onPressed: searchFieldController.text.isNotEmpty
                                ? () {
                              // If text hasn't changes just fuck off
                              if (searchBookView && oldSearch == searchFieldController.text) return;

                                    if (searchFieldController.text.trim().isNotEmpty) {
                                      if (!searchBookView)
                                        Timer.periodic(Duration(milliseconds: 300), (timer) {
                                          if (mounted)
                                            setState(() {
                                              searchBookView = true;
                                            });
                                          timer.cancel();
                                        });
                                      searchBooksList = [];
                                      oldSearch = searchFieldController.text;
                                      mainScreenBloc.add(MainScreenSearchByInputEvent(
                                          searchFieldController.text,
                                          mainList: searchBooksList));
                                    } else {
                                      setState(() {
                                        searchBookView = false;
                                      });
                                    }
                                    FocusScope.of(context).requestFocus(FocusNode());
                            }
                                : null,
                            child: Text(
                              searchFieldController.text.isNotEmpty
                                  ? 'Search'
                                  : searchBookView ? 'Done' : '',
                              style:
                                  TextStyle(fontSize: dimensions.sp14(), color: colorBlueDarkText),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0.0,
                  child: buildRaisedContainer(state),
                ),

                // SHIELD WIDGET Prevent user from pressing anything if screen is blurred
                Positioned(
                  bottom: 0.0,
                  child: searchFieldFocus.hasFocus
                      ? GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            setState(() {});
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height - dimensions.dim95() - 56.0,
                            color: Colors.transparent,
                          ),
                        )
                      : Container(),
                )
              ],
            );
          },
        ),
        bottomNavigationBar: buildBottomNavBar(),
      ),
    );
  }

  Widget searchBooksField(dynamic state) {
    return Container(
      alignment: Alignment.centerLeft,
      height: dimensions.buttonsHeight(),
      margin: EdgeInsets.only(
          left: dimensions.dim8(), bottom: dimensions.dim12(), top: dimensions.dim10()),
      width: MediaQuery.of(context).size.width / 1.5,
      padding: EdgeInsets.only(
          top: dimensions.dim4(), bottom: dimensions.dim4(), left: dimensions.dim8()),
      decoration: ShapeDecoration(
          color: Colors.white.withOpacity(.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(dimensions.mainCornerRadius())),
              side: BorderSide(color: Colors.white))),
      child: CustomTextField(
        controller: searchFieldController,
        focusNode: searchFieldFocus,
        style: TextStyle(),
        decoration: InputDecoration(
          hintText: "Search books",
          hintStyle: TextStyle(fontSize: dimensions.sp14(), color: colorBlueDarkText),
          enabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onSubmitted: (t) {
          // Search field submitted
          if (t.trim().isNotEmpty) {
            Timer.periodic(Duration(milliseconds: 300), (timer) {
              if (mounted)
                setState(() {
                  searchBookView = true;
                });
              timer.cancel();
            });
            searchBooksList = [];
            oldSearch = t;
            mainScreenBloc.add(MainScreenSearchByInputEvent(t, mainList: searchBooksList));
          } else {
            setState(() {
              searchBookView = false;
            });
          }
        },
        onTap: () {
          setState(() {});
        },
        onChanged: (t) {
          setState(() {});
        },
        textInputAction: TextInputAction.done,
      ),
    );
  }

  Widget topCategories(dynamic state) {
    return Container(
      padding: EdgeInsets.all(dimensions.dim6()),
      margin: EdgeInsets.only(left: dimensions.dim6(), right: dimensions.dim6()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim6(),
                right: dimensions.dim16(),
                top: dimensions.dim8(),
                bottom: dimensions.dim16()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: dimensions.sp16(),
                    color: loginTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'see all',
                  style: TextStyle(
                    fontSize: dimensions.sp14(),
                    color: loginTextColor.withOpacity(.66),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Romance
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 1,
                        backgroundColor: Colors.white,
                        elevation: 1,
                        child: Image.asset(categoryRomanceLink,
                            width: dimensions.dim50(), height: dimensions.dim50()),
                        onPressed: () {},
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Romance',
                        style: TextStyle(color: loginTextColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),

                  // Sci fi
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 2,
                        backgroundColor: Colors.white,
                        elevation: 1,
                        child: Image.asset(categorySciFiLink,
                            width: dimensions.dim50(), height: dimensions.dim50()),
                        onPressed: () {},
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sci-fi',
                        style: TextStyle(color: loginTextColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),

                  // History
//                Column(
//                  children: <Widget>[
//                    FloatingActionButton(
//                      heroTag: 3,
//                      backgroundColor: Colors.white,
//                      elevation: 1,
//                      child: Image.asset(categoryHistory, width: dimensions.dim50(), height: dimensions.dim50()),
//                      onPressed: () {
//
//                      },
//                    ),
//                    SizedBox(height: 4),
//                    Text(
//                      'History',
//                      style: TextStyle(
//                          color: loginTextColor,
//                          fontWeight: FontWeight.bold
//                      ),
//                    )
//                  ],
//                ),

                  // Fantasy
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 4,
                        backgroundColor: Colors.white,
                        elevation: 1,
                        child: Image.asset(categoryFantasyLink,
                            width: dimensions.dim50(), height: dimensions.dim50()),
                        onPressed: () {},
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Fantasy',
                        style: TextStyle(color: loginTextColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  // Horror
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 5,
                        backgroundColor: Colors.white,
                        elevation: 1,
                        child: Image.asset(categoryHorrorLink,
                            width: dimensions.dim50(), height: dimensions.dim50()),
                        onPressed: () {},
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Horror',
                        style: TextStyle(color: loginTextColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  // Thriller
                  Column(
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: '5',
                        backgroundColor: Colors.white,
                        elevation: 1,
                        child: Image.asset(categoryThrillerLink,
                            width: dimensions.dim50(), height: dimensions.dim50()),
                        onPressed: () {},
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Thriller',
                        style: TextStyle(color: loginTextColor, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget recentlyUpdated(dynamic state) {
    return Container(
      padding: EdgeInsets.all(dimensions.dim6()),
      margin: EdgeInsets.only(left: dimensions.dim6(), right: dimensions.dim6(), top: mainPadding),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim6(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Recently Updated',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topLikes(dynamic state) {
    return Container(
      padding: EdgeInsets.all(dimensions.dim6()),
      margin: EdgeInsets.only(left: dimensions.dim6(), right: dimensions.dim6()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim6(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Top Likes',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topQuestions(dynamic state) {
    return Container(
      padding: EdgeInsets.all(dimensions.dim6()),
      margin: EdgeInsets.only(left: dimensions.dim6(), right: dimensions.dim6()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim6(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Top Questions',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget topButtons(dynamic state) {
    return SingleChildScrollView(
      child: Container(
        height: dimensions.dim54(),
        width: MediaQuery.of(context).size.width,
        child: Row(
//          scrollDirection: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Recently updated
            Container(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                  color: Colors.white),
              margin: EdgeInsets.all(dimensions.dim6()),
              padding: EdgeInsets.all(mainPadding),
              child: Text(
                'Recently updated',
                style: TextStyle(fontSize: dimensions.sp14(), color: loginTextColor),
              ),
            ),

            // Top likes
            Container(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                  color: Colors.white),
              margin: EdgeInsets.only(top: dimensions.dim6(), bottom: dimensions.dim6()),
              padding: EdgeInsets.all(mainPadding),
              child: Text(
                'Top likes',
                style: TextStyle(fontSize: dimensions.sp14(), color: loginTextColor),
              ),
            ),

            // Top questions
            Container(
              decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                  color: Colors.white),
              margin: EdgeInsets.all(dimensions.dim6()),
              padding: EdgeInsets.all(mainPadding),
              child: Text(
                'Top questions',
                style: TextStyle(fontSize: dimensions.sp14(), color: loginTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavBar() {
    return BottomNavigationBar(
        onTap: (pos) {
          setState(() {
            bottonNavBarIndex = pos;
          });
        },
        currentIndex: bottonNavBarIndex,
        items: [
          // Home
          BottomNavigationBarItem(
              title: Text(
                'Home',
                style: TextStyle(color: loginTextColor),
              ),
              icon: Icon(
                Icons.home,
              ),
              activeIcon: Icon(
                Icons.home,
                color: colorOrangeDark,
              )),
          // Bookshelf
          BottomNavigationBarItem(
              title: Text(
                'Bookshelf',
                style: TextStyle(color: loginTextColor),
              ),
              icon: Icon(Icons.collections_bookmark),
              activeIcon: Icon(
                Icons.collections_bookmark,
                color: colorOrangeDark,
              )),
          // Profile
          BottomNavigationBarItem(
              title: Text(
                'Profile',
                style: TextStyle(color: loginTextColor),
              ),
              icon: Icon(Icons.person),
              activeIcon: Icon(
                Icons.person,
                color: colorOrangeDark,
              )),
        ]);
  }

  Widget buildRaisedContainer(dynamic state) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: ShapeDecoration(
//        image: DecorationImage(
//          image: AssetImage(
//              searchBooksBackgroundImageLink,
//          ),
//          colorFilter: ColorFilter.mode(Colors.white.withOpacity(.1), BlendMode.overlay),
//          fit: BoxFit.fill,
//        ),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
//                Colors.grey[50],
                Colors.orange.shade100,
                Colors.orange.shade50,
//                Colors.orange.shade50,
//                Colors.orange.shade50,
              ]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(mainPadding * 2),
                topRight: Radius.circular(mainPadding * 2)),
          )),
      alignment: Alignment.bottomCenter,
      height: searchBookView ? MediaQuery.of(context).size.height - dimensions.dim95() - 56.0 : 0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: dimensions.dim42()),
            child: ListView.builder(
                shrinkWrap: true,
                controller: searchBooksScrollController,
                physics: BouncingScrollPhysics(),
                itemCount: state is MainScreenBlocLoadedState
                    ? searchBooksList.isNotEmpty ? searchBooksList.length : 1
                    : state is MainScreenBlocLoadingState && searchBooksList.isNotEmpty
                        ? searchBooksList.length + 1
                        : 1,
                padding: EdgeInsets.only(right: mainPadding, left: dimensions.dim8(), top: dimensions.dim10()),
                itemBuilder: (context, pos) {
                  if (pos == searchBooksList.length) {
                    return Container(
                        alignment: Alignment.center,
                        width: dimensions.dim36(),
                        height: dimensions.dim36(),
                        margin: EdgeInsets.only(top: dimensions.dim6()),
                        child: CircularProgressIndicator());
                  }

                  // If loading more show all + loading indicator
                  if (state is MainScreenBlocLoadingState) {
                    if (searchBooksList.isNotEmpty)
                      return BookWidget(
                          searchBooksList[pos],
                        onBookTapped: (_book) {
                            print(_book.title);
                        },
                      );
                  }

                  if (state is MainScreenBlocLoadedState) {

//                    if (pos == searchBooksList.length){
//                      return Container(
//                          alignment: Alignment.center,
//                          width: dimensions.dim36(),
//                          height: dimensions.dim36(),
//                          child: CircularProgressIndicator());
//                    }

                    // Load more
                    if (pos == searchBooksList.length - 2 && !state.noMoreItems) {
                      mainScreenBloc.add(MainScreenSearchByInputEvent(oldSearch,
                          mainList: searchBooksList));
                    }

                    // No result
                    if (searchBooksList.isEmpty) {
                      return Center(
                        child: Text(
                          'No result...',
                          style: TextStyle(
                            fontSize: dimensions.dim16()
                          ),
                        ),
                      );
                    }

                    return BookWidget(
                        searchBooksList[pos],
                      onBookTapped: (_book) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookPage(searchBooksList[pos])
                          ));
                      },
                    );
                  }

                  return Text('Something happened');
                }),
          ),

          // Close icon
          Positioned(
            top: 0.0,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    searchBookView = false;
                  });
                },
                child: searchBookView
                    ? AnimatedContainer(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.deepOrange.shade100.withOpacity(.5),
                                  Colors.yellow.shade100.withOpacity(.1),
//                        Colors.yellow.shade100,
                                ]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(mainPadding * 2),
                                    topRight: Radius.circular(mainPadding * 2)))),
                        duration: Duration(milliseconds: 200),
//                  margin: EdgeInsets.only(),
                        padding: EdgeInsets.only(
                            right: dimensions.dim22(),
                            top: dimensions.dim6(),
                            bottom: dimensions.dim6()),
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width,
                        height: dimensions.dim50(),
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: dimensions.dim32(),
                        ),
                      )
                    : Container()),
          ),
        ],
      ),
    );

//    return AnimatedContainer(
//      duration: Duration(milliseconds: 300),
//      decoration: ShapeDecoration(
//          color: Colors.white,
//          shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(mainPadding * 2),
//                  topRight: Radius.circular(mainPadding * 2)))),
//      alignment: Alignment.bottomCenter,
//      height: bookSearchView ? MediaQuery.of(context).size.height - dimensions.dim95() - 56.0 : 0,
//      width: MediaQuery.of(context).size.width,
//      child: Center(
//          child: GestureDetector(
//              onTap: () {
//                setState(() {
//                  bookSearchView = false;
//                });
//              },
//              child: Text("AZAZA"))),
//    );
  }
}
