import 'package:booquiz/main.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';

class AddQuestionPage extends StatefulWidget {
  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {

  TextEditingController _questionController = TextEditingController();

  TextEditingController _answer1Controller = TextEditingController();
  TextEditingController _answer2Controller = TextEditingController();
  TextEditingController _answer3Controller = TextEditingController();
  TextEditingController _answer4Controller = TextEditingController();

  int correctAnswer = 0;
  bool showAnswer3 = false, showAnswer4 = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepOrange[100],
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
        title: Text('Add a question'),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () {
          // Unfocus shit
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 56.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepOrange[100],
                Colors.orange[100],
              ]
            )
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[

                // Question field
                Container(
                  padding: EdgeInsets.only(top: dimensions.dim36()),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: dimensions.dim24(), left: dimensions.dim14(), bottom: dimensions.dim8()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Question',
                                style: TextStyle(
                                  fontSize: dimensions.sp18(),
                                  color: Colors.black45,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                            // Erase text
                            _questionController.text.isEmpty ? Container(
                              height: 24,
                            ) : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _questionController.text = '';
                                });
                              },
                              child: Icon(
                                Icons.close,
                                size: 24,
                                color: Colors.black45,
                              ),
                            )

                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: mainPadding),
                        padding: EdgeInsets.symmetric(horizontal: mainPadding),
                        decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(dimensions.dim12())),
                            )
                        ),
                        child: TextField(
                          onChanged: (_t) {
                            setState(() {});
                          },
                          controller: _questionController,
                          style: TextStyle(
                            fontSize: dimensions.sp16()
                          ),
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                          maxLength: 120,
                        ),
                      ),
                    ],
                  ),
                ),

                // Answer 1
                Container(
                  margin: EdgeInsets.only(top: dimensions.dim36(), right: dimensions.dim24(), left: dimensions.dim18(), bottom: dimensions.dim8()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Answer 1',
                          style: TextStyle(
                              fontSize: dimensions.sp17(),
                              color: Colors.black45,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // Erase text
                      _answer1Controller.text.isEmpty ? Container(
                        height: 24,
                      ) : GestureDetector(
                        onTap: () {
                          setState(() {
                            _answer1Controller.text = '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black45,
                        ),
                      )

                    ],
                  ),
                ),
                Container(
                  height: dimensions.dim36(),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      )
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Answer field
                      CustomTextField(

                        onChanged: (_t) {
                          setState(() {});
                        },
                        controller: _answer1Controller,
                        style: TextStyle(
                            fontSize: dimensions.sp16()
                        ),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        maxLines: 1,
                        maxLength: 40,
                      ),

                      // Right answer picker
                      Positioned(
                        right: 0,
                        child: Tooltip(
                          message: 'Correct answer',
                          child: Container(
                            decoration: ShapeDecoration(
                              color: Colors.grey[100],
                              shape: CircleBorder(

                              )
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                      )



                    ],
                  ),
                ),

                // Answer 2
                Container(
                  margin: EdgeInsets.only(top: dimensions.dim18(), right: dimensions.dim24(), left: dimensions.dim18(), bottom: dimensions.dim8()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Answer 2',
                          style: TextStyle(
                              fontSize: dimensions.sp17(),
                              color: Colors.black45,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // Erase text
                      _answer2Controller.text.isEmpty ? Container(
                        height: 24,
                      ) : GestureDetector(
                        onTap: () {
                          setState(() {
                            _answer2Controller.text = '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black45,
                        ),
                      )

                    ],
                  ),
                ),
                Container(
                  height: dimensions.dim36(),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      )
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Answer field
                      CustomTextField(

                        onChanged: (_t) {
                          setState(() {});
                        },
                        controller: _answer2Controller,
                        style: TextStyle(
                            fontSize: dimensions.sp16()
                        ),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        maxLines: 1,
                        maxLength: 40,
                      ),

                      // Right answer picker
                      Positioned(
                        right: 0,
                        child: Tooltip(
                          message: 'Correct answer',
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.grey[100],
                                shape: CircleBorder(

                                )
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                      )



                    ],
                  ),
                ),

                // Answer 3
                showAnswer3 ? Container(
                  margin: EdgeInsets.only(top: dimensions.dim18(), right: dimensions.dim24(), left: dimensions.dim18(), bottom: dimensions.dim8()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Answer 3',
                          style: TextStyle(
                              fontSize: dimensions.sp17(),
                              color: Colors.black45,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // Erase text
                      _answer3Controller.text.isEmpty ? Container(
                        height: 24,
                      ) : GestureDetector(
                        onTap: () {
                          setState(() {
                            _answer3Controller.text = '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black45,
                        ),
                      )

                    ],
                  ),
                ) :
                    // Show add button
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: dimensions.dim18(), right: dimensions.dim24(), left: dimensions.dim8(), bottom: dimensions.dim8()),
                  child: MaterialButton(
                    padding: EdgeInsets.zero,
                    minWidth: dimensions.dim44(),
                    elevation: 0,
                    splashColor: Colors.white,
                    highlightColor: Colors.transparent,
                    shape: CircleBorder(),
                    color: Colors.white30,
                    onPressed: () {
                    },
                    child: Icon(
                      Icons.add,
                      color: Colors.green[200],
                    ),
                  ),
                ),
                showAnswer3 ? Container(
                  height: dimensions.dim36(),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      )
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Answer field
                      CustomTextField(

                        onChanged: (_t) {
                          setState(() {});
                        },
                        controller: _answer3Controller,
                        style: TextStyle(
                            fontSize: dimensions.sp16()
                        ),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        maxLines: 1,
                        maxLength: 40,
                      ),

                      // Right answer picker
                      Positioned(
                        right: 0,
                        child: Tooltip(
                          message: 'Correct answer',
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.grey[100],
                                shape: CircleBorder(

                                )
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                      )



                    ],
                  ),
                ) : Container(),


                // Answer 4
                showAnswer4 ? Container(
                  margin: EdgeInsets.only(top: dimensions.dim18(), right: dimensions.dim24(), left: dimensions.dim18(), bottom: dimensions.dim8()),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Answer 4',
                          style: TextStyle(
                              fontSize: dimensions.sp17(),
                              color: Colors.black45,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      // Erase text
                      _answer4Controller.text.isEmpty ? Container(
                        height: 24,
                      ) : GestureDetector(
                        onTap: () {
                          setState(() {
                            _answer4Controller.text = '';
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.black45,
                        ),
                      )

                    ],
                  ),
                ) : Container(),
                showAnswer4 ? Container(
                  height: dimensions.dim36(),
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                  decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      )
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      // Answer field
                      CustomTextField(

                        onChanged: (_t) {
                          setState(() {});
                        },
                        controller: _answer4Controller,
                        style: TextStyle(
                            fontSize: dimensions.sp16()
                        ),
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          border: InputBorder.none,
                        ),
                        maxLines: 1,
                        maxLength: 40,
                      ),

                      // Right answer picker
                      Positioned(
                        right: 0,
                        child: Tooltip(
                          message: 'Correct answer',
                          child: Container(
                            decoration: ShapeDecoration(
                                color: Colors.grey[100],
                                shape: CircleBorder(

                                )
                            ),
                            child: Icon(
                              Icons.done,
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                      )



                    ],
                  ),
                ) : Container(),




              ],
            ),
          ),
        ),
      ),
    );
  }

}
