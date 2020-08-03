import 'dart:async';

import 'package:booquiz/models/Book.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/ui/custom_widgets/quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/tools/firebase/firestore_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booquiz/blocs/blocs.dart';

class QuizPage extends StatefulWidget {
  final Book book;

  QuizPage(this.book);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int quizLimit = 10;
  double cardOffset = 0;

  Timer timer;
  String _timerTime = '0:00';

  PageController pageViewController = PageController();

  @override
  void initState() {
    quizPageBloc.add(QuizPageLoadQuestionsEvent(widget.book.quiz, widget.book, quizLimit));
    _buildTimer();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: quizPageBloc,
      builder: (context, state) {
        return Scaffold(
            appBar: AppBar(
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
              title: Container(
//                width: dimensions.dim180(),
//                margin: EdgeInsets.only(top: dimensions.dim6()),
                alignment: Alignment.bottomCenter,
                child: Text(
                  widget.book.title,
                  style: TextStyle(fontSize: dimensions.sp16()),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                Container(
                  width: dimensions.dim80(),
                  margin: EdgeInsets.only(left: dimensions.dim12()),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: dimensions.dim22(),
                      ),
                      SizedBox(width: dimensions.dim4()),
                      Text(
                        _timerTime,
                        style: TextStyle(fontSize: dimensions.sp16(), color: Colors.white),
                      )
                    ],
                  ),
                )
              ],
            ),
            extendBodyBehindAppBar: true,
            body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.deepOrange[200],
                    Colors.deepOrange[200],
                    Colors.deepOrange[100],
                    Colors.orange[100],
                  ])),
              child: Container(
                  alignment: Alignment.center,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: dimensions.dim80()),
                        height: dimensions.dim40(),
                        alignment: Alignment.topCenter,
                        child: Text(
                          'Question ${widget.book.questionsCompleted + 1} / ${widget.book.questionsLength}',
                          style: TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: dimensions.dim40()),
                          child: QuizSwipeCard(
                              minWidth: dimensions.dim200(),
                              minHeight: dimensions.dim80(),
                              maxHeight: dimensions.dim650(),
                              maxWidth: MediaQuery.of(context).size.width,
                              allowVerticalMovement: false,
                              totalNum: widget.book.quiz.length,
                              onDragEnd: () {
                                setState(() {
                                  cardOffset = 0;
                                });
                              },
                              swipeUpdateCallback: (_details, _alignment) {
                                setState(() {
                                  cardOffset = _alignment.x / 8;
                                });
                              },
                              onLikedPressed: () {
                                print(1);
                              },
                              onDislikedPressed: () {
                                print(2);
                              },
                              cardBuilder: (context, pos) {
                                return Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white70,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(dimensions.dim24())),
                                        side: BorderSide(color: Colors.white54, width: 2)),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      // Main question
                                      Container(
                                        height: dimensions.dim160(),
                                        padding:
                                            EdgeInsets.symmetric(horizontal: dimensions.dim46()),
                                        margin: EdgeInsets.only(bottom: dimensions.dim20()),
                                        alignment: Alignment.center,
                                        decoration: ShapeDecoration(
                                            color: Colors.deepOrange[200].withOpacity(.6),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(dimensions.dim45()),
                                                    bottomLeft: Radius.circular(dimensions.dim45()),
                                                    topLeft: Radius.circular(dimensions.dim20()),
                                                    topRight: Radius.circular(dimensions.dim20())),
                                                side: BorderSide(
                                                    color: Colors.orange[400].withOpacity(.5)))),
                                        child: Text(
                                          widget.book.quiz.first.question,
                                          style: TextStyle(
                                              color: loginTextColor,
                                              fontSize: dimensions.sp20(),
                                              fontWeight: FontWeight.w600,
                                              wordSpacing: 2,
                                              height: 1.5),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      Expanded(
                                          child: _buildYesNoCard(widget.book.quiz.first, state))
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ),
                    ],
                  )),
            ));
      },
    );
  }

  Widget _buildYesNoCard(Question question, dynamic state) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // No
        MaterialButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(dimensions.dim24()))),
          padding: EdgeInsets.zero,
          height: dimensions.dim350(),
          minWidth: dimensions.dim155(),
          splashColor: Colors.red[200],
          highlightColor: Colors.red[100],
          color: cardOffset.isNegative
              ? Colors.red[200].withOpacity(cardOffset.abs() > 1 ? 1 : cardOffset.abs())
              : Colors.transparent,
          elevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          child: Text(
            '< No',
            style: TextStyle(
              fontSize: dimensions.sp20() + -cardOffset * 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Divider
        Container(
          height: dimensions.dim350(),
          margin: EdgeInsets.only(bottom: mainPadding, top: mainPadding),
          width: 1,
          color: Colors.orange[100],
        ),

        // Yes
        MaterialButton(
          onPressed: () {},
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(dimensions.dim24()))),
          padding: EdgeInsets.zero,
          height: dimensions.dim350(),
          minWidth: dimensions.dim155(),
          highlightColor: Colors.green[100],
          hoverColor: Colors.green[100],
          color: cardOffset.isNegative
              ? Colors.transparent
              : Colors.green[200].withOpacity(cardOffset > 1 ? 1 : cardOffset),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,
          splashColor: Colors.green[200],
          child: Text(
            'Yes >',
            style: TextStyle(
              fontSize: dimensions.sp20() + cardOffset * 10,
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswers(Question question, dynamic state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(question.answers.length, (_pos) {
        return Container(
//          width: MediaQuery.of(context).size.width - dimensions.dim24(),
//          height: dimensions.dim60(),
          padding:
              EdgeInsets.symmetric(horizontal: dimensions.dim16(), vertical: dimensions.dim20()),
          margin: EdgeInsets.only(
              top: _pos == 0 ? dimensions.dim12() : 0,
              bottom: _pos == question.answers.length - 1 ? dimensions.dim12() : dimensions.dim12(),
              right: dimensions.dim2(),
              left: dimensions.dim2()),
          alignment: Alignment.centerLeft,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(dimensions.dim24())))),
          child: Text(question.answers[_pos]),
        );
      }),
    );
  }

  void _buildTimer() {
    int _timerSeconds = 0;
    int _timerMinutes = 0;

    timer = Timer.periodic(Duration(seconds: 1), (_t) {
      if (mounted) {
        setState(() {
          if (_t.tick > 59) {
            _timerMinutes = _t.tick ~/ 60;
            _timerSeconds = (_timerMinutes * 60 - _t.tick).abs().toInt();
          } else if (_t.tick < 10) {
            _timerSeconds = _t.tick;
          } else if (_t.tick >= 10 && _t.tick <= 59) {
            _timerSeconds = _t.tick;
          }
        });

        // Format timer string
        _timerTime = '$_timerMinutes:${_timerSeconds < 10 ? '0$_timerSeconds' : '$_timerSeconds'}';
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    pageViewController?.dispose();
    super.dispose();
  }
}
