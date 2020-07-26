import 'dart:ui';

import 'package:booquiz/blocs/add_question_bloc.dart';
import 'package:booquiz/main.dart';
import 'package:booquiz/models/Book.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/ui/custom_widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// List if errors
enum _Errors { question, answer1, answer2, answer3, answer4 }

class AddQuestionPage extends StatefulWidget {
  final Book book;

  AddQuestionPage(this.book);

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  TextEditingController _questionController = TextEditingController();

  TextEditingController _answer1Controller = TextEditingController();
  TextEditingController _answer2Controller = TextEditingController();
  TextEditingController _answer3Controller = TextEditingController();
  TextEditingController _answer4Controller = TextEditingController();

  int correctAnswer = 1;
  bool showAnswer3 = false, showAnswer4 = false;

  List<_Errors> errorList = [];

  @override
  void initState() {
    super.initState();

    addQuestionBloc.listen((state) {

      if (state is AddQuestionLoadedState){
//        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.of(context).pop(state.question);
//        });
      }

    });

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: addQuestionBloc,
      builder: (context, state) {

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
            actions: <Widget>[
              Tooltip(
                message: 'Done',
                child: Container(
                  padding: EdgeInsets.only(right: dimensions.dim6()),
                  child: IconButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      if (validateQuestion()){

                        // Call bloc
                        if (showAnswer3){
                          if (showAnswer4){
                            addQuestionBloc.add(AddQuestionEvent(
                                widget.book, _questionController.text.trim(), correctAnswer == 1 ? _answer1Controller : correctAnswer == 2 ? _answer2Controller.text.trim() : correctAnswer == 3 ? _answer3Controller.text.trim() : _answer4Controller.text.trim(),
                                _answer1Controller.text.trim(), _answer2Controller.text.trim(), answer3: _answer3Controller.text.trim(), answer4: _answer4Controller.text.trim()
                            ));
                          } else {
                            addQuestionBloc.add(AddQuestionEvent(
                                widget.book, _questionController.text.trim(), correctAnswer == 1 ? _answer1Controller : correctAnswer == 2 ? _answer2Controller.text.trim() : correctAnswer == 3 ? _answer3Controller.text.trim() : _answer4Controller.text.trim(),
                                _answer1Controller.text.trim(), _answer2Controller.text.trim(), answer3: _answer3Controller.text.trim()
                            ));
                          }
                        } else {
                          addQuestionBloc.add(AddQuestionEvent(
                              widget.book, _questionController.text.trim(), correctAnswer == 1 ? _answer1Controller.text.trim() == '' ? 'Yes' : _answer1Controller.text.trim() : _answer2Controller.text.trim() == '' ? 'No' : _answer2Controller.text.trim(),
                              _answer1Controller.text.trim(), _answer2Controller.text.trim()
                          ));
                        }

                      }
                    },
                    icon: state is AddQuestionLoadingState ? CircularProgressIndicator(backgroundColor: Colors.orangeAccent.shade400.withOpacity(.5),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) :
                    Icon(Icons.done, color: Colors.white, size: dimensions.dim28(),),
                  ),
                ),
              )
            ],
            title: Text(
              'Add a question',
              style: TextStyle(color: Colors.black54),
            ),
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
                  gradient:
                  LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                    Colors.deepOrange[100],
                    Colors.orange[100],
                  ])),
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
                            margin: EdgeInsets.only(
                                right: dimensions.dim24(),
                                left: dimensions.dim14(),
                                bottom: dimensions.dim8()),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Erase text
                                _questionController.text.isEmpty
                                    ? Container(
                                  height: 24,
                                )
                                    : GestureDetector(
                                  onTap: () {
                                    _questionController.text = '';
                                    setState(() {});
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
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: mainPadding),
                            padding: EdgeInsets.symmetric(horizontal: mainPadding),
                            decoration: ShapeDecoration(
                                color: Colors.white30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(dimensions.dim12())),
                                    side: BorderSide(
                                        color: errorList.contains(_Errors.question)
                                            ? Colors.red[200]
                                            : Colors.white,
                                        width: 3))),
                            child: TextField(
                              onChanged: (_t) {
                                if (_t.trim().isNotEmpty && errorList.contains(_Errors.question))
                                  errorList.remove(_Errors.question);
                                setState(() {});
                              },
                              controller: _questionController,
                              style: TextStyle(fontSize: dimensions.sp16()),
                              decoration: InputDecoration(
                                errorText: _questionController.text.length < 15
                                    ? _questionController.text.length == 14
                                    ? '1 more character required'
                                    : '${15 - _questionController.text.length} more characters required'
                                    : '',
                                hintText: 'What is the name of the main character?',
                                errorStyle: TextStyle(color: Colors.orangeAccent[300]),
                                hintStyle:
                                TextStyle(fontSize: dimensions.sp16(), color: Colors.grey),
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
                      margin: EdgeInsets.only(
                          top: dimensions.dim36(),
                          right: dimensions.dim24(),
                          left: dimensions.dim18(),
                          bottom: dimensions.dim8()),
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
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Erase text
                          _answer1Controller.text.isEmpty
                              ? Container(
                            height: 24,
                          )
                              : GestureDetector(
                            onTap: () {
                              setState(() {
                                _answer1Controller.text = '';
                              });
                              validateQuestion();
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
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: dimensions.dim44(),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(right: mainPadding, left: mainPadding),
                      padding: EdgeInsets.only(right: mainPadding, left: mainPadding),
                      decoration: ShapeDecoration(
                          color: Colors.white30,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                              side: BorderSide(
                                  color: errorList.contains(_Errors.answer1)
                                      ? Colors.red[200]
                                      : Colors.white,
                                  width: 2))),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          // Answer field
                          Container(
                            padding: EdgeInsets.only(right: dimensions.dim36()),
                            child: CustomTextField(
                              onChanged: (_t) {
                                validateQuestion();
                                setState(() {});
                              },
                              controller: _answer1Controller,
                              style: TextStyle(fontSize: dimensions.sp16()),
                              decoration: InputDecoration(
                                hintText: 'Yes',
                                hintStyle:
                                TextStyle(fontSize: dimensions.sp16(), color: Colors.grey),
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                              maxLines: 1,
                              maxLength: 40,
                            ),
                          ),

                          // Correct answer picker
                          Positioned(
                            right: 0,
                            child: Tooltip(
                              message: 'Correct answer',
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    correctAnswer = 1;
                                  });
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                      color: correctAnswer == 1 ? Colors.orange : Colors.white,
                                      shape: CircleBorder()),
                                  child: Icon(
                                    Icons.done,
                                    color: correctAnswer == 1 ? Colors.white : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // Answer 2
                    Container(
                      margin: EdgeInsets.only(
                          top: dimensions.dim18(),
                          right: dimensions.dim24(),
                          left: dimensions.dim18(),
                          bottom: dimensions.dim8()),
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
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          // Erase text
                          _answer2Controller.text.isEmpty
                              ? Container(
                            height: 24,
                          )
                              : GestureDetector(
                            onTap: () {
                              setState(() {
                                _answer2Controller.text = '';
                              });
                              validateQuestion();
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
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: dimensions.dim44(),
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.symmetric(horizontal: mainPadding),
                      padding: EdgeInsets.symmetric(horizontal: mainPadding),
                      decoration: ShapeDecoration(
                          color: Colors.white30,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                              side: BorderSide(
                                  color: errorList.contains(_Errors.answer2)
                                      ? Colors.red[200]
                                      : Colors.white,
                                  width: 2))),
                      child: Stack(
                        fit: StackFit.expand,
                        alignment: Alignment.centerLeft,
                        children: <Widget>[
                          // Answer field
                          CustomTextField(
                            onChanged: (_t) {
                              validateQuestion();
                              setState(() {});
                            },
                            controller: _answer2Controller,
                            style: TextStyle(fontSize: dimensions.sp16()),
                            decoration: InputDecoration(
                              hintText: 'No',
                              hintStyle:
                              TextStyle(fontSize: dimensions.sp16(), color: Colors.grey),
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
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    correctAnswer = 2;
                                  });
                                },
                                child: Container(
                                  decoration: ShapeDecoration(
                                      color: correctAnswer == 2 ? Colors.orange : Colors.white,
                                      shape: CircleBorder()),
                                  child: Icon(
                                    Icons.done,
                                    color: correctAnswer == 2 ? Colors.white : Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    // Answer 3
                    Stack(
                      children: <Widget>[
                        AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: showAnswer3 ? 1 : 0,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      top: dimensions.dim18(),
                                      right: dimensions.dim24(),
                                      left: dimensions.dim18(),
                                      bottom: dimensions.dim8()),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: dimensions.dim10()),
                                            child: Text(
                                              'Answer 3',
                                              style: TextStyle(
                                                  fontSize: dimensions.sp17(),
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),

                                          // Erase Answer
                                          GestureDetector(
                                            onTap: () {
                                              if (correctAnswer == 3 || correctAnswer == 4)
                                                correctAnswer -= 1;
                                              errorList
                                                  .remove(_Errors.answer3); // Remove error if exists

                                              if (showAnswer4) {
                                                _answer3Controller.text = _answer4Controller.text;
                                                _answer4Controller.text = '';
                                              }

                                              if (showAnswer4) {
                                                setState(() {
                                                  showAnswer4 = false;
                                                });
                                              } else {
                                                setState(() {
                                                  showAnswer3 = false;
                                                });
                                              }
                                            },
                                            child: Tooltip(
                                              message: 'Erase answer',
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white70,
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 24,
                                                  color: Colors.red[200],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      _answer3Controller.text.isEmpty
                                          ? Container(
                                        height: 24,
                                      )
                                          : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _answer3Controller.text = '';
                                          });
                                          validateQuestion();
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
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: dimensions.dim44(),
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                                  decoration: ShapeDecoration(
                                      color: Colors.white30,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(24)),
                                          side: BorderSide(
                                              color: errorList.contains(_Errors.answer3)
                                                  ? Colors.red[200]
                                                  : Colors.white,
                                              width: 2))),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.centerLeft,
                                    children: <Widget>[
                                      // Answer field
                                      CustomTextField(
                                        onChanged: (_t) {
                                          validateQuestion();
                                          setState(() {});
                                        },
                                        enabled: showAnswer3,
                                        controller: _answer3Controller,
                                        style: TextStyle(fontSize: dimensions.sp16()),
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
                                          child: GestureDetector(
                                            onTap: () {
                                              if (showAnswer3) {
                                                setState(() {
                                                  correctAnswer = 3;
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                  color: correctAnswer == 3 ? Colors.orange : Colors.white,
                                                  shape: CircleBorder()),
                                              child: Icon(
                                                Icons.done,
                                                color: correctAnswer == 3 ? Colors.white : Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                        showAnswer3
                            ? Container()
                        // Show add button
                            : Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                              top: dimensions.dim18(),
                              right: dimensions.dim24(),
                              left: dimensions.dim8(),
                              bottom: dimensions.dim8()),
                          child: MaterialButton(
                            padding: EdgeInsets.zero,
                            minWidth: dimensions.dim44(),
                            elevation: 0,
                            splashColor: Colors.white,
                            highlightColor: Colors.transparent,
                            shape: CircleBorder(),
                            color: Colors.white30,
                            onPressed: () {
                              setState(() {
                                showAnswer3 = true;
                              });
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green[200],
                            ),
                          ),
                        )
                      ],
                    ),

                    // Answer 4
                    Stack(
                      children: <Widget>[
                        AnimatedOpacity(
                            duration: Duration(milliseconds: 300),
                            opacity: showAnswer4 ? 1 : 0,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(
                                      top: dimensions.dim18(),
                                      right: dimensions.dim24(),
                                      left: dimensions.dim18(),
                                      bottom: dimensions.dim8()),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(right: dimensions.dim10()),
                                            child: Text(
                                              'Answer 4',
                                              style: TextStyle(
                                                  fontSize: dimensions.sp17(),
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),

                                          // Erase Answer
                                          GestureDetector(
                                            onTap: () {
                                              if (correctAnswer == 3 || correctAnswer == 4)
                                                correctAnswer -= 1;
                                              errorList
                                                  .remove(_Errors.answer4); // Remove error if exists

                                              if (showAnswer4) {
                                                setState(() {
                                                  showAnswer4 = false;
                                                });
                                              }
                                            },
                                            child: Tooltip(
                                              message: 'Erase answer',
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.white70,
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 24,
                                                  color: Colors.red[200],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      // Erase text
                                      _answer4Controller.text.isEmpty
                                          ? Container(
                                        height: 24,
                                      )
                                          : GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _answer4Controller.text = '';
                                          });
                                          validateQuestion();
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
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  height: dimensions.dim44(),
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.symmetric(horizontal: mainPadding),
                                  padding: EdgeInsets.symmetric(horizontal: mainPadding, vertical: 4),
                                  decoration: ShapeDecoration(
                                      color: Colors.white30,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(24)),
                                          side: BorderSide(
                                              color: errorList.contains(_Errors.answer4)
                                                  ? Colors.red[200]
                                                  : Colors.white,
                                              width: 2))),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.centerLeft,
                                    children: <Widget>[
                                      // Answer field
                                      CustomTextField(
                                        onChanged: (_t) {
                                          validateQuestion();
                                          setState(() {});
                                        },
                                        enabled: showAnswer4,
                                        controller: _answer4Controller,
                                        style: TextStyle(fontSize: dimensions.sp16()),
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
                                          child: GestureDetector(
                                            onTap: () {
                                              if (showAnswer4) {
                                                setState(() {
                                                  correctAnswer = 4;
                                                });
                                              }
                                            },
                                            child: Container(
                                              decoration: ShapeDecoration(
                                                  color: correctAnswer == 4 ? Colors.orange : Colors.white,
                                                  shape: CircleBorder()),
                                              child: Icon(
                                                Icons.done,
                                                color: correctAnswer == 4 ? Colors.white : Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )),
                        showAnswer4 || !showAnswer3 && !showAnswer4
                            ? Container()
                        // Show add button
                            : Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(
                              top: dimensions.dim18(),
                              right: dimensions.dim24(),
                              left: dimensions.dim8(),
                              bottom: dimensions.dim8()),
                          child: MaterialButton(
                            padding: EdgeInsets.zero,
                            minWidth: dimensions.dim44(),
                            elevation: 0,
                            splashColor: Colors.white,
                            highlightColor: Colors.transparent,
                            shape: CircleBorder(),
                            color: Colors.white30,
                            onPressed: () {
                              setState(() {
                                showAnswer4 = true;
                              });
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green[200],
                            ),
                          ),
                        )
                      ],
                    ),

                    SizedBox(
                      height: dimensions.dim16(),
                    )
                  ],
                ),
              ),
            ),
          ),
        );

      },
    );
  }

  bool validateQuestion() {
    String answ1 = _answer1Controller.text.trim();
    String answ2 = _answer2Controller.text.trim();
    String answ3 = _answer3Controller.text.trim();
    String answ4 = _answer4Controller.text.trim();

    // Check question
    if (_questionController.text.length < 15) return false;

    if (_questionController.text.trim().isEmpty) {
      setState(() {
        errorList.add(_Errors.question);
      });
      return false;
    } else {
      errorList.remove(_Errors.question);
    }

    // Check 1 & 2
    if (answ1.isNotEmpty && answ2.isNotEmpty) {
      if (answ1 == answ2) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer2);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer2);
        setState(() {});
      }
    }

    if (!checkDuplicateAnswers(answ1, answ2, answ3, answ4)) {
      return false;
    }

    if (showAnswer3 || showAnswer4) {
      // Check duplicate answers 1 & 3
      if (answ1 == answ3 && answ1.isNotEmpty && answ3.isNotEmpty) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer3);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer3);
        setState(() {});
      }

      // Check duplicate answers 1 & 4
      if (answ1 == answ4 && answ1.isNotEmpty && answ1.isNotEmpty && answ4.isNotEmpty) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }

      // Check duplicate answers 2 & 3
      if (answ2 == answ3 && answ2.isNotEmpty && answ3.isNotEmpty) {
        setState(() {
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer3);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer3);
        setState(() {});
      }

      // Check duplicate answers 2 & 4
      if (answ2 == answ4 && answ2.isNotEmpty && answ4.isNotEmpty) {
        setState(() {
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }

      // Check duplicate answers 3 & 4
      if (answ3 == answ4 && answ3.isNotEmpty && answ4.isNotEmpty) {
        setState(() {
          errorList.add(_Errors.answer3);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer3);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }
    }

    return true;
  }

  bool checkDuplicateAnswers(String answ1, String answ2, String answ3, String answ4) {
    // Check tripple duplicates

    // 1, 2, 3
    if (answ1.isNotEmpty && answ2.isNotEmpty && answ3.isNotEmpty) {
      if (answ1 == answ2 && answ1 == answ3) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer3);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer3);
        setState(() {});
      }
    }
    // 1, 3, 4
    if (answ1.isNotEmpty && answ3.isNotEmpty && answ4.isNotEmpty) {
      if (answ1 == answ3 && answ1 == answ4) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer3);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer3);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }
    }

    // 1, 2, 4
    if (answ1.isNotEmpty && answ2.isNotEmpty && answ4.isNotEmpty) {
      if (answ1 == answ2 && answ1 == answ4) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }
    }

    // 2, 3, 4
    if (answ2.isNotEmpty && answ3.isNotEmpty && answ4.isNotEmpty) {
      if (answ2 == answ3 && answ2 == answ4) {
        setState(() {
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer3);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer3);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }
    }

    // Check all duplicates
    if (answ1.isNotEmpty && answ2.isNotEmpty && answ3.isNotEmpty && answ4.isNotEmpty) {
      if (answ1 == answ2 && answ1 == answ3 && answ1 == answ4) {
        setState(() {
          errorList.add(_Errors.answer1);
          errorList.add(_Errors.answer2);
          errorList.add(_Errors.answer3);
          errorList.add(_Errors.answer4);
        });
        return false;
      } else {
        errorList.remove(_Errors.answer1);
        errorList.remove(_Errors.answer2);
        errorList.remove(_Errors.answer3);
        errorList.remove(_Errors.answer4);
        setState(() {});
      }
    }
    return true;
  }

  @override
  void dispose() {
    _questionController?.dispose();
    _answer1Controller?.dispose();
    _answer2Controller?.dispose();
    _answer3Controller?.dispose();
    _answer4Controller?.dispose();
    super.dispose();
  }
}
