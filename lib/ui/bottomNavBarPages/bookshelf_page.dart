import 'dart:async';
import 'dart:ui';

import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/ui/custom_widgets/book_widget.dart';
import 'package:booquiz/ui/custom_widgets/bookshelf_book_widget.dart';
import 'package:booquiz/ui/custom_widgets/custom_loading_indicator.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:booquiz/ui/sliver_app_bar_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookshelfPage extends StatefulWidget {
  @override
  _BookshelfPageState createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;

  FocusNode searchFieldFocus = FocusNode();

  String oldSearch = '';

  int limit = 10;

  // Show in progress or completed books
  bool inProgressSelected = true;

  // Controllers
  TextEditingController searchFieldController = TextEditingController();
  PageController _pageViewController = PageController();
  ScrollController searchBooksScrollController = ScrollController();

  ScrollController _inProgressListController = ScrollController();
  ScrollController _completedListController = ScrollController();

  List<UserBook> listInProgress = [];
  List<UserBook> completedList = [];

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);

    // Load books in progress
    bookshelfPageBloc.add(BookshelfPageLoadInProgressEvent(listInProgress, limit: limit));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bookshelfPageBloc,
      builder: (context, state) {
        return Container(
            height: MediaQuery.of(context).size.height -
                dimensions.dim58(), // Height minus nav bar height]
            child: CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: <Widget>[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverAppBarDelegate(
                      minHeight: dimensions.dim140(),
                      maxHeight: dimensions.dim140(),
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
                        padding: EdgeInsets.only(top: dimensions.dim36()),
                        child: Column(
                          children: <Widget>[
                            // Search field
                            Row(
                              children: <Widget>[
                                searchBarWidget(),
                                Container(
                                  margin: EdgeInsets.only(left: mainPadding),
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(mainPadding))),
                                    onPressed: () {},
                                    child: Text(
                                      searchFieldController.text.isNotEmpty ? 'Search' : '',
                                      style: TextStyle(
                                          fontSize: dimensions.sp14(), color: colorBlueDarkText),
                                    ),
                                  ),
                                )
                              ],
                            ),

                            // Tab bar
                            Container(
                              alignment: Alignment.topCenter,
                              height: dimensions.dim40(),
                              width: dimensions.dim300(),
                              child: TabBar(
                                controller: _tabController,
                                indicatorSize: TabBarIndicatorSize.label,
                                indicatorColor: Colors.orange,
                                tabs: [
                                  Container(
                                    child: Tab(
                                      child: Text(
                                        'In progress',
                                        softWrap: true,
                                        style: TextStyle(
                                            color: Colors.black38, fontSize: dimensions.sp15()),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Tab(
                                      child: Text(
                                        'Completed',
                                        style: TextStyle(
                                            color: Colors.black38, fontSize: dimensions.sp15()),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Background color
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                Colors.orange[100].withOpacity(.5),
                                Colors.white30.withOpacity(.5),
                                Colors.white70.withOpacity(.5),
                                Colors.deepOrange[50].withOpacity(.5),
                              ])),
                        ),

                        Container(
                          height: MediaQuery.of(context).size.height - dimensions.dim200(),
                          alignment: Alignment.topCenter,
                          child: PageView(
                            controller: _pageViewController,
                            children: <Widget>[
                              inProgressWidget(state),
                              completedWidget(state),
                            ],
                          ),
                        )
                      ],
                    )
                  ]),
                )
              ],
            ));
      },
    );
  }

  Widget searchBarWidget() {
    return Hero(
      tag: 'searchBarWidget',
      child: Container(
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
          },
          onTap: () {},
          onChanged: (t) {},
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }

  Widget inProgressWidget(dynamic state) {

    // First loading indicator
    if (state is BookshelfPageLoadingState && state.mList.isEmpty){
      return Container(
        alignment: Alignment.center,
        child: CustomLoadingIndicator(),
      );

    } else {

      return GridView.builder(
          itemCount: state is BookshelfPageInProgressLoadedState
              ? listInProgress.length
              : inProgressSelected && state is BookshelfPageLoadingState
              ? listInProgress.length + 1 // Main shit + loading indicator
              : 1,

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, pos) {

            // Show bottom loading indicator
            if (state is BookshelfPageLoadingState && listInProgress.isNotEmpty){
              if (pos == listInProgress.length - 1)
                return CustomLoadingIndicator();
              else
                return BookshelfBookWidget(
                    mainBook: listInProgress[pos]);
            }

            if (state is BookshelfPageInProgressLoadedState && listInProgress.isNotEmpty){
              return Container(
//                padding: EdgeInsets.only(left: dimensions.dim24(), right: dimensions.dim24(), bottom: dimensions.dim8()),
                child: BookshelfBookWidget(
                  mainBook: listInProgress[pos]
                ),
              );
            }
            else {
              return Container(
                child: Text(
                  'No books yet =\\',
                  style: TextStyle(
                      fontSize: dimensions.sp14(),
                      color: loginTextColor
                  ),
                ),
              );
            }

          });
    }
  }

  Widget completedWidget(dynamic state) {
    return ListView.builder(
      controller: _completedListController,
      itemCount: state is BookshelfPageCompletedLoadedState
          ? completedList.length
          : !inProgressSelected && state is BookshelfPageLoadingState
          ? completedList.length + 1 // Main shit + loading indicator
          : 1,
      itemBuilder: (context, pos) {
        return Container();
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
