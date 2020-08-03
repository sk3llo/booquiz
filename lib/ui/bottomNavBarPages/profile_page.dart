import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/ui/custom_widgets/custom_loading_indicator.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polygon_clipper/polygon_border.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {

  bool editModeOn = false;
  TextEditingController aboutMeController = TextEditingController();
  FocusNode aboutMeFocus = FocusNode();

  @override
  void initState() {
    aboutMeController.text = currentUser.aboutMe;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: profilePageBloc,
      builder: (context, state) {
        return Scaffold(
//          extendBodyBehindAppBar: true,
          resizeToAvoidBottomPadding: false,
          appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width, dimensions.dim60()),
            child: Material(
              color: Colors.white.withOpacity(0),
              child: AnimatedContainer(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.deepOrange.shade200,
                          Colors.deepOrange.shade100,
                        ])),
                alignment: Alignment.bottomRight,
                height: dimensions.dim120(),
                width: dimensions.dim60(),
                padding: EdgeInsets.only(right: dimensions.dim16()),
                duration: Duration(milliseconds: 300),
                child:
                state is ProfilePageLoadingState ? Container(
                  alignment: Alignment.centerRight,
                  height: dimensions.dim40(),
                  width: dimensions.dim40(),
                  child: CustomLoadingIndicator(),
                ) :
                IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: editModeOn ? 28 : 24,
                  onPressed: () {

                    if (editModeOn){
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (currentUser.aboutMe.isEmpty){
                        profilePageBloc.add(ProfilePageUpdateAboutMeEvent(aboutMeController.text.trim()));
                      } else {
                        // Check for duplicate
                        if (aboutMeController.text.trim() != currentUser.aboutMe.trim()){
                          profilePageBloc.add(ProfilePageUpdateAboutMeEvent(aboutMeController.text.trim()));
                        } else {
                        }
                      }
                    }

                    setState(() {
                      editModeOn = !editModeOn;
                    });

//                    setState(() {
//                      editModeOn = !editModeOn;
//                    });
                  },
                  icon: Icon(editModeOn ? Icons.done : Icons.edit, color: Colors.white),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: dimensions.dim20(), left: dimensions.dim20()),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.deepOrange.shade100,
                        Colors.orange.shade100,
                        Colors.orange.shade100,
                        Colors.orange.shade100,
                      ])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Profile picture button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: dimensions.dim4()),
                        height: dimensions.dim100(),
                        width: dimensions.dim100(),
                        decoration: ShapeDecoration(
                          shape: PolygonBorder(
                              sides: 6, border: BorderSide(color: Colors.white70, width: 4)),
                        ),
                        child: FloatingActionButton(
                          splashColor: Colors.white,
                          focusColor: Colors.white,
                          backgroundColor: Colors.deepOrange.shade200,
                          elevation: 0,
                          focusElevation: 0,
                          highlightElevation: 0,
                          shape: PolygonBorder(sides: 6),
                          onPressed: () {},
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: dimensions.dim34(),
                          ),
                        ),
                      ),

                      // Username and questions added
                      Column(
                        children: <Widget>[
                          // Username
                          Container(
                            decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(mainPadding),
                                        topLeft: Radius.circular(mainPadding)),
                                    side: BorderSide(color: Colors.white30.withOpacity(.1)))),
                            margin:
                                EdgeInsets.only(left: dimensions.dim4(), top: dimensions.dim14()),
                            width: MediaQuery.of(context).size.width / 1.75,
                            padding: EdgeInsets.only(
                                left: dimensions.dim12(),
                                top: dimensions.dim8(),
                                bottom: dimensions.dim8()),
                            child: Text(
                              currentUser.username,
                              style: TextStyle(
                                  color: loginTextColor,
                                  fontSize: dimensions.sp22(),
                                  fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Questions added
                          Container(
                            decoration: ShapeDecoration(
//                                  gradient: LinearGradient(
//                                      begin: Alignment.centerLeft,
//                                      end: Alignment.centerRight,
//                                      colors: [
//                                        Colors.white.withOpacity(.05),
//                                        Colors.white.withOpacity(.1),
//                                        Colors.white.withOpacity(.1),
//                                        Colors.white.withOpacity(.1),
//                                        Colors.white.withOpacity(.05),
//                                        Colors.orange.shade400.withOpacity(.05),
//                                      ]),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(mainPadding),
                                        topLeft: Radius.circular(mainPadding)),
                                    side: BorderSide(color: Colors.white30.withOpacity(.1)))),
                            margin: EdgeInsets.only(left: dimensions.dim4()),
                            width: MediaQuery.of(context).size.width / 1.75,
                            padding: EdgeInsets.only(
                                left: dimensions.dim12(),
                                top: dimensions.dim8(),
                                bottom: dimensions.dim8()),
                            child: Text(
                              currentUser.questionsCount == 1
                                  ? currentUser.questionsCount.toString() + ' question added'
                                  : currentUser.questionsCount.toString() + ' questions added',
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: dimensions.sp16(),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      )
                    ],
                  ),

                  // Followers and following
                  Container(
                    margin: EdgeInsets.only(top: dimensions.dim36(), right: dimensions.dim32()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // Followers
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: dimensions.dim4()),
                              child: Text(
                                'Followers:',
                                style: TextStyle(
                                  fontSize: dimensions.sp17(),
                                  color: Colors.black54
                                ),
                              ),
                            ),

                            Text(
                              '0',
                              style: TextStyle(
                                  fontSize: dimensions.sp17(),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                            )
                          ],
                        ),

                        Container(),

                        // Following
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(vertical: dimensions.dim4()),
                              child: Text(
                                'Following:',
                                style: TextStyle(
                                    fontSize: dimensions.sp17(),
                                    color: Colors.black54
                                ),
                              ),
                            ),
                            Text(
                              '0',
                              style: TextStyle(
                                  fontSize: dimensions.sp17(),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54
                              ),
                            )
                          ],
                        ),

                      ],
                    ),
                  ),

                  // About you
                  Container(
                    padding: EdgeInsets.only(top: dimensions.dim32()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: dimensions.dim6()),
                          padding: EdgeInsets.only(bottom: mainPadding),
                          child: Text(
                            'About you:',
                            style: TextStyle(color: loginTextColor, fontSize: dimensions.sp16()),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: MediaQuery.of(context).size.width - dimensions.dim42(),
                          height: dimensions.dim135(),
                          padding: EdgeInsets.symmetric(
                              horizontal: mainPadding, vertical: dimensions.dim4()),
                          decoration: ShapeDecoration(
                              color: editModeOn ? Colors.white54 : Colors.white.withOpacity(0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(24)),
                                  side: BorderSide(color: Colors.white70, width: 2))),
                          child: TextField(
                            controller: aboutMeController,
                            focusNode: aboutMeFocus,
                            style: TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                                focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, disabledBorder: InputBorder.none),
                            maxLines: 4,
                            maxLength: 140,
                            enabled: editModeOn,
                          ),
                        )
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
