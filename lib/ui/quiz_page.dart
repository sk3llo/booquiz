import 'dart:async';

import 'package:booquiz/models/MainBook.dart';
import 'package:booquiz/models/UserBook.dart';
import 'package:booquiz/models/Question.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/ui/custom_widgets/custom_loading_indicator.dart';
import 'package:booquiz/ui/custom_widgets/quiz_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:booquiz/tools/firebase/firestore_utils.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booquiz/blocs/blocs.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:overlay_support/overlay_support.dart';

class QuizPage extends StatefulWidget {
  final MainBook mainBook;
  final UserBook userBook;

  QuizPage(this.mainBook, this.userBook);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int quizLimit = 10;
  int finishQuizAnimPos = 0; // Finish Quiz (0 - first text fade out, 1 - 2nd etc.)
  double cardOffset = 0;

  List<Question> listOfCompletedQuiz = [];

  Timer timer;
  int _timerSeconds = 0;
  int _timerMinutes = 0;
  String _timerTime = '0:00';

  int selectedAnswerPos = -1;
  bool showResults = false;

  PageController pageViewController = PageController();
  CardController cardController = CardController();

  AnimationController finishQuizAnimController;
  SequenceAnimation finishQuizSequenceAnimation;
  List<AnimationController> completedQuizControllers = [];
  List<SequenceAnimation> completedQuizSequenceAnim = [];

  @override
  void initState() {

    _initControllers();

    if (widget.mainBook.quiz.isNotEmpty)
      widget.mainBook.quiz.removeWhere((q) => q.completedAt != null);

    // Trigger bloc to load questions
    quizPageBloc.add(QuizPageLoadQuestionsEvent(
        widget.mainBook, widget.userBook, quizLimit, finishQuizAnimController));
    _buildTimer(startTimeMilliseconds: widget.userBook.totalTimeTaken);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: quizPageBloc,
      builder: (context, state) {
        bool _completedQuiz = state is QuizPageLoadedState &&
                state.userBook != null &&
                state.mainBook != null &&
                state.userBook.questionsCompleted == state.mainBook.questionsLength ||
            state is QuizPageEmptyState &&
                state.userBook != null &&
                state.mainBook != null &&
                state.userBook.questionsCompleted == state.mainBook.questionsLength;

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
                      if (!_completedQuiz) {
                        int _totalTimeTaken = (_timerMinutes * 60 + _timerSeconds) * 1000;
                        quizPageBloc
                            .add(QuizPageUpdateTotalTimeTakenEvent(widget.mainBook, widget.userBook,
                            _totalTimeTaken));
                      }
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
                  widget.mainBook.title,
                  style: TextStyle(fontSize: dimensions.sp16()),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                Container(
                  width: dimensions.dim81(),
                  margin: EdgeInsets.only(left: dimensions.dim12()),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: dimensions.dim18(),
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
              width: MediaQuery.of(context).size.width,
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
                        height: dimensions.dim120(),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: dimensions.dim6()),
                              height: dimensions.dim60(),
                              alignment: Alignment.bottomCenter,
                              child: AnimatedOpacity(
                                duration: Duration(milliseconds: 600),
                                opacity: widget.userBook.questionsCompleted ==
                                        widget.mainBook.questionsLength
                                    ? 0
                                    : 1,
                                child: Text(
                                  'Question ${widget.userBook.questionsCompleted == widget.mainBook.questionsLength ? widget.userBook.questionsCompleted : widget.userBook.questionsCompleted + 1} / ${widget.mainBook.questionsLength}',
                                  style:
                                      TextStyle(fontSize: dimensions.sp14(), color: Colors.white),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              height: dimensions.dim80(),
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.bottomCenter,
                              child: _completedQuiz && showResults
                                  ? MaterialButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Expand All',
                                        style: TextStyle(
                                            color: Colors.purple[300], fontSize: dimensions.sp15()),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                          child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          // Finish quiz screen
                          if (_completedQuiz) _buildFinishQuiz(state),

                          // Main cards
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 400),
                            height: _completedQuiz ? 0 : MediaQuery.of(context).size.height,
                            width: _completedQuiz ? 0 : MediaQuery.of(context).size.width,
                            child: Container(
                              margin: EdgeInsets.only(bottom: dimensions.dim40()),
                              child: QuizSwipeCard(
                                  minWidth: dimensions.dim200(),
                                  minHeight: dimensions.dim400(),
                                  maxHeight: dimensions.dim500(),
                                  maxWidth: MediaQuery.of(context).size.width,
                                  allowVerticalMovement: false,
                                  stackNum: 3,
                                  totalNum: state is QuizPageLoadedState ||
                                          state is QuizPageEmptyState &&
                                              state.mainBook != null &&
                                              state.mainBook.quiz.isNotEmpty
                                      ? state.mainBook.quiz.length
                                      : widget.mainBook.quiz.length,
                                  allQuiz: state is QuizPageLoadedState &&
                                          state.mainBook != null &&
                                          state.mainBook.quiz.isNotEmpty
                                      ? state.mainBook.quiz
                                      : widget.mainBook.quiz,
                                  cardController: cardController,
                                  onDragEnd: () {
                                    setState(() {
                                      cardOffset = 0;
                                    });
                                  },
                                  swipeCompleteCallback: (_or, pos) {
                                    // If swiped trigger bloc
                                    if (_or == CardSwipeOrientation.LEFT ||
                                        _or == CardSwipeOrientation.RIGHT)
                                      _pickAnAnswer(widget.mainBook.quiz[pos], orintation: _or);
                                    else {
                                      setState(() {
                                        selectedAnswerPos = -1;
                                      });
                                    }
                                  },
                                  swipeUpdateCallback: (_details, _alignment) {
                                    cardOffset = _alignment.x / 8;
                                    if (cardOffset > 25) cardOffset = 25.0;
                                    setState(() {});
                                  },
                                  likeButton: FloatingActionButton(
                                    shape: CircleBorder(
                                        side: BorderSide(color: Colors.white54, width: 2)),
                                    backgroundColor: Colors.deepOrange[100],
                                    splashColor: Colors.green[300],
                                    onPressed: () {
                                      print(timer.tick * 1000);
                                    },
                                    highlightElevation: 0,
                                    focusElevation: 0,
                                    elevation: 0,
                                    heroTag: 'zhzhzh',
                                    child: Icon(
                                      Icons.thumb_up,
                                    ),
                                  ),
                                  dislikeButton: FloatingActionButton(
                                    shape: CircleBorder(
                                        side: BorderSide(color: Colors.white54, width: 2)),
                                    backgroundColor: Colors.deepOrange[100],
                                    splashColor: Colors.redAccent[200],
                                    onPressed: () {},
                                    highlightElevation: 0,
                                    focusElevation: 0,
                                    elevation: 0,
                                    heroTag: 'hzhzhz',
                                    child: Icon(Icons.thumb_down),
                                  ),
                                  cardBuilder: (context, pos) {
                                    return Container(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(dimensions.dim24())),
                                            side: BorderSide(color: Colors.white54, width: 2)),
                                      ),
                                      child: Column(
                                        children: <Widget>[
                                          // Main question
                                          Container(
                                            height: dimensions.dim160(),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: dimensions.dim46()),
//                                        margin: EdgeInsets.only(bottom: dimensions.dim20()),
                                            alignment: Alignment.center,
                                            decoration: ShapeDecoration(
                                                color: Colors.deepOrange[200].withOpacity(.6),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(dimensions.dim45()),
                                                        bottomLeft:
                                                            Radius.circular(dimensions.dim45()),
                                                        topLeft:
                                                            Radius.circular(dimensions.dim20()),
                                                        topRight:
                                                            Radius.circular(dimensions.dim20())),
                                                    side: BorderSide(
                                                        color:
                                                            Colors.orange[400].withOpacity(.5)))),
                                            child: Text(
                                              state is QuizPageLoadedState ||
                                                      state is QuizPageEmptyState &&
                                                          state.mainBook != null &&
                                                          state.mainBook.quiz.isNotEmpty
                                                  ? state.mainBook.quiz[pos].question
                                                  : widget.mainBook.quiz[pos].question,
                                              style: TextStyle(
                                                  color: loginTextColor,
                                                  fontSize: dimensions.sp20(),
                                                  fontWeight: FontWeight.w600,
                                                  wordSpacing: 2,
                                                  height: 1.5),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),

                                          buildShit(state, pos)
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      )),
                    ],
                  )),
            ));
      },
    );
  }

  Widget _buildYesNoCard(Question question, dynamic state, int pos) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: dimensions.dim8()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          // Left button
          Expanded(
            child: MaterialButton(
              onPressed: () {
                selectedAnswerPos = 0;
                cardController.triggerLeft();
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(dimensions.dim24()))),
              padding: EdgeInsets.symmetric(horizontal: dimensions.dim16()),
              height: dimensions.dim350(),
              splashColor: Colors.blue[200],
              highlightColor: Colors.blue[50],
              color: cardOffset.isNegative
                  ? pos == 0 ||
                          widget.mainBook.questionsLength - widget.userBook.questionsCompleted == 1
                      ? Colors.blue[200].withOpacity(cardOffset.abs() > 1 ? 1 : cardOffset.abs())
                      : Colors.transparent
                  : Colors.transparent,
              elevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '<',
                      style: TextStyle(
                        fontSize:
                            pos != 0 ? dimensions.dim20() : dimensions.sp20() + -cardOffset * 10,
                        color: Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: dimensions.dim20()),
                    alignment: Alignment.center,
                    child: Text(
                      question?.answers[0] ?? '',
                      style: TextStyle(
                        fontSize:
                            pos != 0 ? dimensions.dim20() : dimensions.sp20() + -cardOffset * 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 7,
                    ),
                  ),
                ],
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

          // Right button
          Expanded(
            child: MaterialButton(
              onPressed: () {
                selectedAnswerPos = 1;
                cardController.triggerRight();
              },
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.only(bottomRight: Radius.circular(dimensions.dim24()))),
              padding: EdgeInsets.symmetric(horizontal: dimensions.dim16()),
              height: dimensions.dim350(),
              highlightColor: Colors.green[50],
              hoverColor: Colors.green[100],
              color: pos != 0
                  ? Colors.transparent
                  : cardOffset.isNegative
                      ? Colors.transparent
                      : Colors.green[100].withOpacity(cardOffset > 1 ? 1 : cardOffset),
              elevation: 0,
              highlightElevation: 0,
              focusElevation: 0,
              splashColor: Colors.green[200],
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ' >',
                      style: TextStyle(
                        fontSize:
                            pos != 0 ? dimensions.dim20() : dimensions.sp20() + cardOffset * 10,
                        color: Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(right: dimensions.dim20()),
                    child: Text(
                      question?.answers[1] ?? '',
                      style: TextStyle(
                        fontSize:
                            pos != 0 ? dimensions.dim20() : dimensions.sp20() + cardOffset * 10,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleAnswersCard(Question question, dynamic state, int cardPos) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(question.answers.length, (_pos) {
        return GestureDetector(
          onTap: () async {
            if (selectedAnswerPos == _pos) {
              if (selectedAnswerPos > 1) {
                cardController.triggerLeft();
              } else {
                cardController.triggerRight();
              }

              question.answered = question.answers[_pos];
              _pickAnAnswer(question);
              return;
            } else {
              setState(() {
                selectedAnswerPos = _pos;
              });
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
                horizontal: dimensions.dim16(),
                vertical: (question.answers[_pos]).length >= 32
                    ? dimensions.dim12()
                    : dimensions.dim18()),
            margin: EdgeInsets.only(
                top: _pos == 0 ? dimensions.dim8() : dimensions.dim4(),
                bottom: _pos == question.answers.length - 1 ? dimensions.dim8() : dimensions.dim4(),
                right: dimensions.dim6(),
                left: dimensions.dim6()),
            alignment: Alignment.centerLeft,
            decoration: ShapeDecoration(
                color: selectedAnswerPos == _pos
                    ? Colors.blueAccent.shade100.withOpacity(.5)
                    : Colors.blueGrey.shade100.withOpacity(.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(dimensions.dim24())))),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: dimensions.dim220(),
                  child: Text(
                    question.answers[_pos],
                    style: TextStyle(color: Colors.black87, fontSize: dimensions.sp15()),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: dimensions.dim4()),
                  width: dimensions.dim20(),
                  height: dimensions.dim20(),
                  child: AnimatedOpacity(
                    opacity: selectedAnswerPos == _pos ? 1 : 0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      Icons.done,
                      color: Colors.green.shade200,
                      size: dimensions.dim16(),
                    ),
                  ),
                  decoration: ShapeDecoration(
                      color: selectedAnswerPos == _pos ? Colors.white : Colors.transparent,
                      shape: CircleBorder(
                          side: BorderSide(
                              color: selectedAnswerPos == _pos ? Colors.white : Colors.grey[400],
                              width: 2))),
                )
              ],
            ),
          ),
        );
      })
        ..add(GestureDetector(
          onTap: () {
            setState(() {
              selectedAnswerPos = -1;
            });
          },
          child: AnimatedOpacity(
            opacity: selectedAnswerPos != -1 ? 1 : 0,
            duration: Duration(milliseconds: 300),
            child: Text(
              // Add bottom info text
              'Press again to choose',
              style: TextStyle(
                  fontSize: dimensions.sp12(),
                  color: Colors.blueGrey.shade200,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )),
    );
  }

  Widget buildShit(dynamic state, int pos) {
    try {
      return Expanded(
          child: state is QuizPageLoadedState ||
                  state is QuizPageEmptyState &&
                      state.mainBook != null &&
                      state.mainBook.quiz.isNotEmpty
              ? state.mainBook.quiz[pos].answers.length > 2
                  ? _buildMultipleAnswersCard(state.mainBook.quiz[pos], state, pos)
                  : _buildYesNoCard(state.mainBook.quiz[pos], state, pos)
              : widget.mainBook.quiz.isNotEmpty && widget.mainBook.quiz[pos].answers.length > 2
                  ? _buildMultipleAnswersCard(widget.mainBook.quiz[pos], state, pos)
                  : _buildYesNoCard(widget.mainBook.quiz[pos], state, pos));
    } catch (e) {
      return Container();
    }
  }

  void _buildTimer({int startTimeMilliseconds}) {
    if (startTimeMilliseconds != null && startTimeMilliseconds != 0) {
      _timerMinutes =
          (startTimeMilliseconds / 60000 < 0 ? 0 : startTimeMilliseconds / 60000).toInt();
      _timerSeconds = (widget.userBook.totalTimeTaken / 1000 -
              ((widget.userBook.totalTimeTaken / 60000 < 0
                          ? 0
                          : widget.userBook.totalTimeTaken / 60000)
                      .toInt() *
                  60))
          .toInt();
      setState(() {
        _timerTime = '$_timerMinutes:${_timerSeconds < 10 ? '0$_timerSeconds' : '$_timerSeconds'}';
      });

      if (widget.userBook.questionsCompleted == widget.mainBook.questionsLength) {
        return;
      }
    }

    timer = Timer.periodic(Duration(seconds: 1), (_t) {
      if (mounted && widget.userBook.questionsCompleted != widget.mainBook.questionsLength) {
        setState(() {
          if (_timerSeconds == 59) {
            _timerMinutes = _timerMinutes + 1;
            _timerSeconds = 0;
          } else {
            _timerSeconds += 1;
          }

          // Format timer string
          _timerTime =
              '$_timerMinutes:${_timerSeconds < 10 ? '0$_timerSeconds' : '$_timerSeconds'}';
        });
      }
    });
  }

  void _pickAnAnswer(Question question, {CardSwipeOrientation orintation}) {
    bookDebug('quiz_page.dart', '_pickAnAnswer', 'INFO', 'Picking answer...');

    try {
      int _timer = (_timerMinutes * 60 + _timerSeconds) * 1000;
      if (orintation != null) {
        if (orintation == CardSwipeOrientation.LEFT) {
          question.answered = question.answers[0];
        } else if (orintation == CardSwipeOrientation.RIGHT) {
          question.answered = question.answers[1];
        }
      }

      listOfCompletedQuiz.add(question);
      quizPageBloc.add(QuizPageCompleteQuestionEvent(widget.mainBook, widget.userBook,
          listOfCompletedQuiz.last, _timer, finishQuizAnimController));
    } catch (e) {
      bookDebug('quiz_page.dart', '_pickAnAnswer', 'ERROR', e.toString());
    }

    // If picked answer by clicking, not swiping, update [selectedAnswerPos] on swipe callback
    if (selectedAnswerPos <= 1) {
      setState(() {
        selectedAnswerPos = -1;
      });
    }
  }

  Widget _buildFinishQuiz(dynamic state) {
    return AnimatedBuilder(
      animation: finishQuizAnimController,
      builder: (context, _pos) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Results
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: showResults ? 1 : 0,
              child: state is QuizPageLoadedState ||
                      state is QuizPageEmptyState && state.mainBook != null
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.topCenter,
                      child: ListView.builder(
                        itemCount: state.mainBook.completedQuiz.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, pos) {
                          // Result question
                          return _buildResultQuestion(context, pos, state);
                        },
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      child: CustomLoadingIndicator()),
            ),

            // Finish quiz
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: showResults ? 0 : MediaQuery.of(context).size.height,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: showResults ? 0 : 1,
                child: Visibility(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Congrats
                        Opacity(
                          opacity: finishQuizSequenceAnimation['1'].value,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: dimensions.dim50(),
                            alignment: Alignment.topCenter,
                            child: Text(
                              'Congratulations!',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: dimensions.sp24(),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Image
                        Center(
                            child: Opacity(
                                opacity: finishQuizSequenceAnimation['1'].value > .25
                                    ? finishQuizSequenceAnimation['1'].value - .25
                                    : 0,
                                child: Image(
                                  image: AssetImage('assets/images/finish_quiz_trophy.png'),
                                  height: dimensions.dim140(),
                                  fit: BoxFit.fill,
                                ))),
                        // Your Score
                        Opacity(
                          opacity: finishQuizSequenceAnimation['1'].value,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: dimensions.dim40(),
                            padding: EdgeInsets.symmetric(horizontal: dimensions.dim10()),
                            margin: EdgeInsets.only(top: dimensions.dim30()),
                            alignment: Alignment.topCenter,
                            child: Text(
                              'YOUR SCORE:',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: dimensions.sp16(),
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Score
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: finishQuizSequenceAnimation['2'].value,
                              child: Container(
                                height: dimensions.dim40(),
                                alignment: Alignment.center,
                                child: Text(
                                  '${widget.userBook.questionsCompleted}',
                                  style: TextStyle(
                                    color: Colors.orangeAccent.shade400.withOpacity(.6),
                                    fontSize: dimensions.sp28(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              opacity: finishQuizSequenceAnimation['2'].value,
                              child: Container(
                                height: dimensions.dim40(),
                                alignment: Alignment.center,
                                child: Text(
                                  '  /  ${widget.mainBook.questionsLength}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: dimensions.sp28(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Quote and indicator
                        Stack(
                          children: [
                            // Loading indicator
                            Opacity(
                              opacity: state is QuizPageLoadedState && state.quote == null
                                  ? finishQuizSequenceAnimation['4'].value
                                  : 0,
                              child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: dimensions.dim80(),
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      height: dimensions.dim20(),
                                      width: dimensions.dim20(),
                                      alignment: Alignment.bottomCenter,
                                      child:
                                          Opacity(opacity: .4, child: CustomLoadingIndicator()))),
                            ),
                            // Quote
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              opacity: state is QuizPageLoadedState && state.quote != null ? 1 : 0,
                              child: Opacity(
                                opacity: finishQuizSequenceAnimation['4'].value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Quote
                                    Container(
                                      color: Colors.purple.withOpacity(.025),
                                      padding: EdgeInsets.symmetric(
                                          vertical: dimensions.dim6(),
                                          horizontal: dimensions.dim12()),
                                      alignment: Alignment.center,
                                      child: Text(
                                        state is QuizPageLoadedState
                                            ? state.quote != null
                                                ? state.quote['quote'] ?? ''
                                                : ''
                                            : '',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: dimensions.sp16()),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    // Author
                                    Container(
                                      // color: Colors.orange.withOpacity(.1),
                                      padding: EdgeInsets.symmetric(
                                          vertical: dimensions.dim6(),
                                          horizontal: dimensions.dim16()),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        state is QuizPageLoadedState
                                            ? state.quote != null
                                                ? state.quote['authors'] ?? ''
                                                : ''
                                            : '',
                                        style: TextStyle(
                                            color: Colors.red.withOpacity(.5),
                                            fontSize: dimensions.sp16(),
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        Container(
                          height: dimensions.dim80(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 'Show result' button
            Positioned(
              bottom: 0.0,
              child: Container(
                color: Colors.orange[100],
                height: dimensions.dim80(),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Opacity(
                      opacity: finishQuizSequenceAnimation['4'].value,
                      child: Container(
                        margin: EdgeInsets.only(bottom: dimensions.dim30()),
                        alignment: Alignment.bottomCenter,
                        child: MaterialButton(
                          key: Key('keyKEEEYOMGKEEYOMG'),
                          minWidth: dimensions.dim180(),
                          onPressed: () {
                            setState(() {
                              showResults = !showResults;
                            });
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: dimensions.dim32(), vertical: dimensions.dim16()),
                          color: Colors.blue.shade200,
                          elevation: 0,
                          child: Text(
                            'SHOW RESULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: dimensions.sp14(),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: finishQuizSequenceAnimation['4'].value,
                      child: Container(
                        margin: EdgeInsets.only(bottom: dimensions.dim30()),
                        alignment: Alignment.bottomCenter,
                        child: MaterialButton(
                          key: Key('keyKEEEYOMGKEEYOMG'),
                          minWidth: dimensions.dim180(),
                          onPressed: () {
                            if (finishQuizSequenceAnimation['4'].value == 1) {
                              Navigator.of(context).pop();
                            }
                          },
                          padding: EdgeInsets.symmetric(
                              horizontal: dimensions.dim32(), vertical: dimensions.dim16()),
                          color: Colors.orange.shade400,
                          elevation: 0,
                          child: Text(
                            'Return',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: dimensions.sp14(),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  String _buildMinutes(int totalTimeTaken) {
    return '${(totalTimeTaken / 60000 < 0 ? 0 : totalTimeTaken / 60000).toInt()}';
  }

  String _buildSeconds(int totalTimeTaken) {
    int _sec = totalTimeTaken / 1000 < 0
        ? 0
        : (totalTimeTaken / 1000 -
                ((totalTimeTaken / 60000 < 0 ? 0 : totalTimeTaken / 60000).toInt() * 60))
            .toInt();
    if (_sec < 10)
      return '0$_sec';
    else
      return '$_sec';
  }

  @override
  void dispose() {
    // Empty state
    quizPageBloc.add(QuizPageNullStateEvent());
    finishQuizAnimController
      ..reset()
      ..dispose();

    completedQuizControllers.forEach((_animC) {
      _animC
        ..reset()
        ..dispose();
    });

    timer?.cancel();
    pageViewController?.dispose();
    super.dispose();
  }

  // State is QuizLoaded or QuizEmpty
  Widget _buildResultQuestion(BuildContext context, int pos, dynamic state) {
    Question _q = state.mainBook.completedQuiz[pos];

    return AnimatedBuilder(
      animation: completedQuizControllers[pos],
      builder: (context, _pos) {
        return Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.only(bottom: dimensions.dim12()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Question number
              Container(
                margin: EdgeInsets.only(left: dimensions.dim12()),
                child: Text(
                  (pos + 1).toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: dimensions.sp20(),
                      fontWeight: FontWeight.bold),
                ),
              ),

              // Question
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_q.expanded) {
                      _q.expanded = false;
                      await completedQuizControllers[pos].reverse();
                    } else {
                      _q.expanded = true;
                      await completedQuizControllers[pos].forward();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width - dimensions.dim80(),
                    height: completedQuizSequenceAnim[pos]['1'].value,
                    margin: EdgeInsets.only(right: dimensions.dim16(), left: dimensions.dim12()),
                    decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            side: BorderSide(color: Colors.white))),
                    child: Column(
                      children: [
                        // Main question
                        Container(
                          decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(14)),
                                  side: BorderSide(color: Colors.white54))),
                          padding: EdgeInsets.symmetric(vertical: dimensions.dim6()),
                          child: Row(
                            children: [
                              Container(
                                  margin: EdgeInsets.only(
                                      left: dimensions.dim12(), top: dimensions.dim4()),
                                  child: Text('Q: ',
                                      style: TextStyle(
                                          color: Colors.purple[300], fontSize: dimensions.sp15()))),
                              Container(
                                width: MediaQuery.of(context).size.width - dimensions.dim90(),
                                margin: EdgeInsets.only(top: dimensions.dim2()),
                                padding: EdgeInsets.symmetric(horizontal: dimensions.dim4()),
                                height: completedQuizSequenceAnim[pos]['2'].value,
                                alignment: Alignment.center,
                                child: Text(
                                  // 'Ronakdlk awjdlkwajkl djawlkda awdl lkawjdlkw kal djklwdk alwkdjlwkaj lkaw lkdjwalkjdlkwajlkdj lkjawlkdjklwjd kljkawkljdl',
                                  _q.question,
                                  style:
                                      TextStyle(color: Colors.white, fontSize: dimensions.sp15()),
                                  maxLines: completedQuizSequenceAnim[pos]['2'].value !=
                                          dimensions.dim40()
                                      ? 4
                                      : 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Stack(
                          fit: StackFit.loose,
                          children: [
                            // LONG Answers, time taken, other shit
                            Container(
                              height: completedQuizSequenceAnim[pos]['3'].value == 0.0 ? dimensions.dim20() : dimensions.dim20() * (4 + completedQuizSequenceAnim[pos]['3'].value),
                              child: Opacity(
                                opacity: completedQuizSequenceAnim[pos]['3'].value,
                                child: Column(
                                  children: List.generate(_q.answers.length, (i) {
                                    return Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.only(
                                                left: dimensions.dim12(),
                                                right: dimensions.dim8(),
                                                top: dimensions.dim6()),
                                            child: Text(
                                              '${i + 1}.',
                                              style: TextStyle(
                                                  color: Colors.purple[300],
                                                  fontSize: dimensions.sp14() * completedQuizSequenceAnim[pos]['4'].value,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: dimensions.dim6() * completedQuizSequenceAnim[pos]['4'].value),
                                          child: Text(
                                            _q.answers[i],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: dimensions.sp14() * completedQuizSequenceAnim[pos]['4'].value),
                                          ),
                                        )
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),

                            // SHORT Answer and time taken
                            AnimatedOpacity(
                              duration: Duration(milliseconds: 200),
                              opacity:
                                  completedQuizSequenceAnim[pos]['1'].value != dimensions.dim80()
                                      ? 0
                                      : 1,
                              child: Container(
                                height: dimensions.dim20() * (1 - (completedQuizSequenceAnim[pos]['3'].value)),
                                child: Row(
                                  children: [
                                    // Answer
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: dimensions.dim2(),
                                                left: dimensions.dim12(),
                                                right: dimensions.dim2()),
                                            child: Text(
                                              'A: ',
                                              style: TextStyle(
                                                  color: Colors.purple[300],
                                                  fontSize: dimensions.sp15() * (1 - completedQuizSequenceAnim[pos]['3'].value)),
                                            ),
                                          ),
                                          Container(
                                            width: dimensions.dim80(),
                                            margin: EdgeInsets.only(
                                                top: dimensions.dim2() * (1 - completedQuizSequenceAnim[pos]['3'].value),
                                                left: dimensions.dim12(),
                                                right: dimensions.dim2()),
                                            child: Text(
                                              _q.answered,
                                              style: TextStyle(
                                                  color: Colors.white, fontSize: dimensions.sp14() * (1 - completedQuizSequenceAnim[pos]['3'].value)),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Time taken
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: dimensions.dim2(),
                                          left: dimensions.dim12(),
                                          right: dimensions.dim6()),
                                      child: Icon(
                                        Icons.av_timer_sharp,
                                        color: Colors.black54,
                                        size: dimensions.dim18(),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: dimensions.dim4(),
                                          left: dimensions.dim4(),
                                          right: dimensions.dim24()),
                                      child: Text(
                                          '${_buildMinutes(_q.timeTaken)}:${_buildSeconds(_q.timeTaken)}',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: dimensions.sp12())),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _initControllers() {
    int _start = 0;

    // For finish anim screen
    finishQuizAnimController = AnimationController(vsync: this);
    finishQuizSequenceAnimation = SequenceAnimationBuilder()
        .addAnimatable(
        animatable: Tween(begin: 0.0, end: 1.0),
        from: Duration.zero,
        to: Duration(milliseconds: 800),
        tag: '1')
        .addAnimatable(
        animatable: Tween(begin: 0.0, end: 1.0),
        from: Duration(milliseconds: 700),
        to: Duration(milliseconds: 1000),
        tag: '2')
        .addAnimatable(
        animatable: Tween(begin: 0.0, end: 1.0),
        from: Duration(milliseconds: 900),
        to: Duration(milliseconds: 1200),
        tag: '3')
        .addAnimatable(
        animatable: Tween(begin: 0.0, end: 1.0),
        from: Duration(milliseconds: 1100),
        to: Duration(milliseconds: 1400),
        tag: '4')
        .animate(finishQuizAnimController);

    // For each question create new controller
    do {
      _start += 1;

      var _compQuestionAnimController = AnimationController(vsync: this);
      var _compQuestionSequenceAnimation = SequenceAnimationBuilder()
          .addAnimatable(
              animatable: Tween<double>(begin: dimensions.dim80(), end: dimensions.dim180()),
              from: Duration.zero,
              to: Duration(milliseconds: 200),
              tag: '1')
          .addAnimatable(
              animatable: Tween<double>(begin: dimensions.dim40(), end: dimensions.dim60()),
              from: Duration(milliseconds: 300),
              to: Duration(milliseconds: 500),
              tag: '2')
          .addAnimatable(
              animatable: Tween<double>(begin: 0.0, end: 1.0),
              from: Duration(milliseconds: 500),
              to: Duration(milliseconds: 700),
              tag: '3')
          .addAnimatable(
              animatable: Tween<double>(begin: 0.0, end: 1.0),
              from: Duration(milliseconds: 800),
              to: Duration(milliseconds: 1000),
              tag: '4')
          .animate(_compQuestionAnimController);

      completedQuizControllers.add(_compQuestionAnimController);
      completedQuizSequenceAnim.add(_compQuestionSequenceAnimation);
    } while (_start <= widget.mainBook.questionsLength);
  }
}
