import 'dart:async';
import 'dart:ui';

import 'package:booquiz/blocs/bottomNavBar/home_page_bloc.dart';
import 'package:booquiz/models/MainBook.dart';
import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/ui/book_page.dart';
import 'package:booquiz/ui/custom_widgets/book_widget.dart';
import 'package:booquiz/ui/custom_widgets/custom_loading_indicator.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:booquiz/ui/login/login_step1.dart';
import 'package:booquiz/ui/sliver_app_bar_delegate.dart';
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
import 'dart:math' as math;

import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'bookshelf_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  // Search
  TextEditingController searchFieldController = TextEditingController();
  FocusNode searchFieldFocus = FocusNode();
  ScrollController searchBooksScrollController = ScrollController();
  bool searchBookView = false;
  List<MainBook> searchBooksList = [];


  int bottonNavBarIndex = 0;
  int _preserveIndex = 0;

  // Search Books View defs
  String oldSearch = '';

  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

//    HomeScreenBloc.add(GetBooksByCategory());
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
        resizeToAvoidBottomInset: false,
        body: Column(
          children: <Widget>[
            Expanded(
              child: IndexedStack(
                index: _preserveIndex,
                children: <Widget>[
                  // Page 1
                  BlocBuilder(
                    bloc: homePageBloc,
                    builder: (context, state) {
                      return CustomScrollView(
                        physics: BouncingScrollPhysics(),
                        slivers: <Widget>[
                          // APP BAR
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverAppBarDelegate(
                                minHeight: dimensions.dim100(),
                                maxHeight: dimensions.dim100(),
                                child: Container(
                                  decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(mainPadding),
                                              bottomRight: Radius.circular(mainPadding))),
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.red[200],
                                            Colors.deepOrange[100],
                                            Colors.orange[100],
                                          ])),
                                  alignment: Alignment.bottomCenter,
//                        padding: EdgeInsets.only(top: dimensions.dim32()),
                                  child: BackdropFilter(
                                    // Blur filter
                                    filter: ImageFilter.blur(
                                        sigmaX: searchFieldFocus.hasFocus ? 5 : 0,
                                        sigmaY: searchFieldFocus.hasFocus ? 5 : 0),
                                    child: Row(
                                      children: <Widget>[
                                        searchBarWidget(),
                                        Container(
                                          margin: EdgeInsets.only(left: mainPadding),
                                          child: MaterialButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(mainPadding))),
                                            onPressed: searchFieldController.text.isNotEmpty
                                                ? () {
                                              // If text hasn't changes just fuck off
                                              if (searchBookView &&
                                                  oldSearch == searchFieldController.text)
                                                return;

                                              if (searchFieldController.text
                                                  .trim()
                                                  .isNotEmpty) {
                                                if (!searchBookView)
                                                  Timer.periodic(
                                                      Duration(milliseconds: 300), (timer) {
                                                    if (mounted)
                                                      setState(() {
                                                        searchBookView = true;
                                                      });
                                                    timer.cancel();
                                                  });
                                                searchBooksList = [];
                                                oldSearch = searchFieldController.text;
                                                homePageBloc.add(
                                                    HomePageSearchByInputEvent(
                                                        searchFieldController.text,
                                                        mainList: searchBooksList));
                                              } else {
                                                setState(() {
                                                  searchBookView = false;
                                                });
                                              }
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            }
                                                : null,
                                            child: Text(
                                              searchFieldController.text.isNotEmpty
                                                  ? 'Search'
                                                  : searchBookView ? 'Done' : '',
                                              style: TextStyle(
                                                  fontSize: dimensions.sp14(),
                                                  color: colorBlueDarkText),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                          ),

                          // MAIN SHIT
                          SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.orange.shade100,
                                            Colors.orange.shade100,
                                          ])),
                                  child: SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Stack(
                                        children: <Widget>[
                                          // Main Content
                                          Container(
                                            margin: EdgeInsets.only(top: dimensions.dim12()),
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
                                              ],
                                            ),
                                          ),

                                          Positioned(
                                            bottom: 0.0,
                                            left: 0,
                                            right: 0,
                                            child: buildRaisedContainer(state),
                                          ),

                                          // TRANSPARENT SHIELD WIDGET Prevent user from pressing anything if screen is blurred
                                          Positioned(
                                            bottom: 0.0,
                                            child: searchFieldFocus.hasFocus
                                                ? GestureDetector(
                                              onTap: () {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                                setState(() {});
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                height: MediaQuery.of(context).size.height,
                                                color: Colors.white.withOpacity(0),
                                              ),
                                            )
                                                : Container(),
                                          )
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ),

                  // Bookshelf Page
                  BookshelfPage(),

                  // Profile Page
                  ProfilePage()
                ],
              ),
            ),
            buildBottomNavBar()
          ],
        ),
      ),
    );
  }

  Widget searchBarWidget() {
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
        expands: false,
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
            homePageBloc.add(HomePageSearchByInputEvent(t, mainList: searchBooksList));
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
                      Stack(
                        children: <Widget>[
                          // Inner image
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: Image.asset(categoryRomanceLink),
                          ),

                          // Outer button with splash effect
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              splashColor: Colors.red.shade100,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              elevation: 0,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white, width: dimensions.dim3())),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Romance',
                        style: TextStyle(
                            color: loginTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: dimensions.sp14()),
                      )
                    ],
                  ),

                  // Sci fi
                  Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          // Inner image
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: Image.asset(categorySciFiLink),
                          ),

                          // Outer button with splash effect
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              splashColor: Colors.green.shade200,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              elevation: 0,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white, width: dimensions.dim3())),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Sci-fi',
                        style: TextStyle(
                            color: loginTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: dimensions.sp14()),
                      )
                    ],
                  ),

                  // Fantasy
                  Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          // Inner image
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: Image.asset(categoryFantasyLink),
                          ),

                          // Outer button with splash effect
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              splashColor: Colors.purple.shade100,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              elevation: 0,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white, width: dimensions.dim3())),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Fantasy',
                        style: TextStyle(
                            color: loginTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: dimensions.sp14()),
                      )
                    ],
                  ),
                  // Horror
                  Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          // Inner image
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: Image.asset(categoryHorrorLink),
                          ),

                          // Outer button with splash effect
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              splashColor: Colors.grey.shade300,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              elevation: 0,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white, width: dimensions.dim3())),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Horror',
                        style: TextStyle(
                            color: loginTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: dimensions.sp14()),
                      )
                    ],
                  ),

                  // Thriller
                  Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          // Inner image
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: Image.asset(categoryThrillerLink),
                          ),

                          // Outer button with splash effect
                          Container(
                            width: dimensions.dim55(),
                            height: dimensions.dim55(),
                            child: RawMaterialButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              fillColor: Colors.transparent,
                              splashColor: Colors.red.shade200,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              focusElevation: 0,
                              highlightElevation: 0,
                              elevation: 0,
                              shape: CircleBorder(
                                  side: BorderSide(color: Colors.white, width: dimensions.dim3())),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Thriller',
                        style: TextStyle(
                            color: loginTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: dimensions.sp14()),
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
      margin: EdgeInsets.only(top: dimensions.dim18()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim14(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Recently Updated',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: dimensions.dim100(),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: List.generate(
                  5,
                  (i) => Container(
                        height: dimensions.dim100(),
                        width: dimensions.dim80(),
                        margin: EdgeInsets.only(left: mainPadding, right: i == 4 ? mainPadding : 0),
                        padding: EdgeInsets.only(left: mainPadding, right: mainPadding),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                          color: Colors.grey,
                        ),
                        child: Text(
                          'Book ' + (i + 1).toString(),
                          style:
                              TextStyle(fontSize: dimensions.sp14(), color: Colors.orange.shade100),
                        ),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget topLikes(dynamic state) {
    return Container(
      padding: EdgeInsets.only(top: dimensions.dim6()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim14(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Top Likes',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: dimensions.dim100(),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: List.generate(
                  5,
                  (i) => Container(
                        height: dimensions.dim100(),
                        width: dimensions.dim80(),
                        margin: EdgeInsets.only(left: mainPadding, right: i == 4 ? mainPadding : 0),
                        padding: EdgeInsets.only(left: mainPadding, right: mainPadding),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                          color: Colors.blue[300],
                        ),
                        child: Text(
                          'Book ' + (i + 1).toString(),
                          style: TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                        ),
                      )),
            ),
          )
        ],
      ),
    );
  }

  Widget topQuestions(dynamic state) {
    return Container(
      padding: EdgeInsets.only(top: dimensions.dim6(), bottom: dimensions.dim16()),
      decoration: ShapeDecoration(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(mainPadding)))),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.only(
                left: dimensions.dim14(), top: dimensions.dim8(), bottom: dimensions.dim16()),
            child: Text(
              'Top Questions',
              style: TextStyle(
                fontSize: dimensions.sp17(),
                color: loginTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: dimensions.dim100(),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              children: List.generate(
                  5,
                  (i) => Container(
                        height: dimensions.dim100(),
                        width: dimensions.dim80(),
                        margin: EdgeInsets.only(left: mainPadding, right: i == 4 ? mainPadding : 0),
                        padding: EdgeInsets.only(left: mainPadding, right: mainPadding),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(mainPadding))),
                          color: Colors.green,
                        ),
                        child: Text(
                          'Book ' + (i + 1).toString(),
                          style: TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                        ),
                      )),
            ),
          )
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
    try {
      return PersistentBottomNavBar(
          navBarHeight: dimensions.dim58(),
          backgroundColor: Colors.white30,
          hideNavigationBar: false,
          popScreensOnTapOfSelectedTab: false,
          confineToSafeArea: true,
          itemAnimationProperties: ItemAnimationProperties(
            // Navigation Bar's items animation properties.
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
          ),
          onAnimationComplete: (a, b) {},
          selectedIndex: bottonNavBarIndex,
          onItemSelected: (i) {
            if (bottonNavBarIndex != i) {
              bottonNavBarIndex = i;
              _preserveIndex = bottonNavBarIndex;
              setState(() {});
            }
               // TODO: Add 'Continue quiz, Updated book questions, Save for future, Similar books' and Comments sections
          },
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(10.0),
            colorBehindNavBar: Colors.white,
          ),
          items: [
            // Home
            PersistentBottomNavBarItem(
              title: 'Home',
              titleFontSize: bottonNavBarIndex == 0 ? dimensions.sp13() : dimensions.sp12(),
              icon: Icon(
                Icons.home,
              ),
              activeColor: CupertinoColors.systemOrange,
              inactiveColor: CupertinoColors.systemGrey,
            ),
            // Bookshelf
            PersistentBottomNavBarItem(
              title: 'Bookshelf',
              titleFontSize: bottonNavBarIndex == 1 ? dimensions.sp13() : dimensions.sp12(),
              icon: Icon(Icons.collections_bookmark),
              activeColor: CupertinoColors.systemOrange,
              inactiveColor: CupertinoColors.systemGrey,
            ),
            // Profile
            PersistentBottomNavBarItem(
              title: 'Profile',
              titleFontSize: bottonNavBarIndex == 2 ? dimensions.sp13() : dimensions.sp12(),
              icon: Icon(Icons.person),
              activeColor: CupertinoColors.systemOrange,
              inactiveColor: CupertinoColors.systemGrey,
            ),
          ]);
    } catch (e) {
      print(e);
    }
  }

  Widget buildRaisedContainer(dynamic state) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: ShapeDecoration(
          gradient:
              LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Colors.orange.shade100,
            Colors.orange.shade50,
          ]),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(mainPadding * 2),
                topRight: Radius.circular(mainPadding * 2)),
          )),
//      alignment: Alignment.bottomCenter,
      height: searchBookView
          ? MediaQuery.of(context).size.height -
              (bigScreen ? dimensions.dim50() : dimensions.dim40())
          : 0,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(bottom: dimensions.dim90()),
      child: Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: dimensions.dim38()),
            child: ListView.builder(
                shrinkWrap: true,
                controller: searchBooksScrollController,
                physics: BouncingScrollPhysics(),
                itemCount: state is HomePageBlocLoadedState
                    ? searchBooksList.isNotEmpty ? searchBooksList.length : 1
                    : state is HomePageBlocLoadingState && searchBooksList.isNotEmpty
                        ? searchBooksList.length + 1
                        : 1,
                padding: EdgeInsets.only(
                    right: mainPadding,
                    left: dimensions.dim8(),
                    top: dimensions.dim10(),
                    bottom: dimensions.dim32()),
                itemBuilder: (context, pos) {
                  if (pos == searchBooksList.length) {
                    return Container(
                        alignment: Alignment.center,
                        width: dimensions.dim36(),
                        height: dimensions.dim36(),
                        margin: EdgeInsets.only(top: dimensions.dim6()),
                        child: CustomLoadingIndicator());
                  }

                  // If loading more show all + loading indicator
                  if (state is HomePageBlocLoadingState) {
                    if (searchBooksList.isNotEmpty)
                      return BookWidget(
                        searchBooksList[pos],
                        onBookTapped: (_book) {
                          print(_book.title);
                        },
                      );
                  }

                  if (state is HomePageBlocLoadedState) {
                    // Load more
                    if (pos == searchBooksList.length - 2 && !state.noMoreItems) {
                      homePageBloc
                          .add(HomePageSearchByInputEvent(oldSearch, mainList: searchBooksList));
                    }

                    // No result
                    if (searchBooksList.isEmpty) {
                      return Center(
                        child: Text(
                          'No result...',
                          style: TextStyle(fontSize: dimensions.dim16()),
                        ),
                      );
                    }

                    return BookWidget(
                      searchBooksList[pos],
                      onBookTapped: (_book) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookPage(searchBooksList[pos])));
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
                                  Colors.deepOrange.shade200.withOpacity(.4),
                                  Colors.red.shade100.withOpacity(.1),
                                ]),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(mainPadding * 2),
                              topRight: Radius.circular(mainPadding * 2),
                              bottomLeft: Radius.circular(mainPadding * 2),
                              bottomRight: Radius.circular(mainPadding * 2),
                            ))),
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
                          color: Colors.grey[500],
                          size: dimensions.dim32(),
                        ),
                      )
                    : Container()),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
