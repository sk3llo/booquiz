import 'package:booquiz/models/Question.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:flutter/material.dart';
import 'dart:math';

List<Size> _cardSizes = List();
List<Alignment> _cardAligns = List();

/// A Tinder-Like Widget.
class QuizSwipeCard extends StatefulWidget {
  CardBuilder _cardBuilder;
  int _totalNum;
  List<Question> _allQuiz;
  int _stackNum;
  int _animDuration;
  double _swipeEdge;
  double _swipeEdgeVertical;
  bool _swipeUp;
  bool _swipeDown;
  bool _allowVerticalMovement;
  bool _allowHorizontalMovement;
  CardSwipeCompleteCallback swipeCompleteCallback;
  CardDragUpdateCallback swipeUpdateCallback;
  Widget likeButton;
  Widget dislikeButton;

  /// Send drag end callback right away
  Function onDragEnd;
  CardController cardController;

  double _maxWidth;
  double _minWidth;
  double _maxHeight;
  double _minHeight;

  @override
  _QuizSwipeCardState createState() => _QuizSwipeCardState();

  /// Constructor requires Card Widget Builder [cardBuilder] & your card count [totalNum]
  /// , option includes: stack orientation [orientation], number of card display in same time [stackNum]
  /// , [swipeEdge] is the edge to determine action(recover or swipe) when you release your swiping card
  /// it is the value of alignment, 0.0 means middle, so it need bigger than zero.
  /// , and size control params;
  QuizSwipeCard(
      {@required CardBuilder cardBuilder,
      @required int totalNum,
      @required List<Question> allQuiz, // List of all questions
      AmassOrientation orientation = AmassOrientation.BOTTOM,
      int stackNum = 3,
      int animDuration = 800,
      double swipeEdge = 3.0,
      double swipeEdgeVertical = 8.0,
      bool swipeUp = false,
      bool swipeDown = false,
      double maxWidth,
      double maxHeight,
      double minWidth,
      double minHeight,
      bool allowVerticalMovement = true,
      bool allowHorizontalMovement = true,
      this.cardController,
      this.swipeCompleteCallback,
      this.swipeUpdateCallback,
      this.onDragEnd,
      this.likeButton,
      this.dislikeButton})
      : this._cardBuilder = cardBuilder,
        this._totalNum = totalNum,
        this._allQuiz = allQuiz ?? [],
        assert(stackNum > 1),
        this._stackNum = stackNum,
        this._animDuration = animDuration,
        assert(swipeEdge > 0),
        this._swipeEdge = swipeEdge,
        assert(swipeEdgeVertical > 0),
        this._swipeEdgeVertical = swipeEdgeVertical,
        this._swipeUp = swipeUp,
        this._swipeDown = swipeDown,
        assert(maxWidth > minWidth && maxHeight > minHeight),
        this._allowVerticalMovement = allowVerticalMovement,
        this._allowHorizontalMovement = allowHorizontalMovement,
        this._maxWidth = maxWidth,
        this._minWidth = minWidth,
        this._maxHeight = maxHeight,
        this._minHeight = minHeight {
    double widthGap = maxWidth - minWidth;
    double heightGap = maxHeight - minHeight;

    _cardAligns = List();
    _cardSizes = List();

    for (int i = 0; i < _stackNum; i++) {
      if (i == 0) {
        _cardSizes.add(
            Size(minWidth + dimensions.dim100() + (widthGap / _stackNum) * i, minHeight + dimensions.dim22() + (heightGap / _stackNum) * i));
      } else if (i == 1) {
        _cardSizes.add(
            Size(minWidth + dimensions.dim50() + (widthGap / _stackNum) * i, minHeight + dimensions.dim10() + (heightGap / _stackNum) * i));
      } else {
        _cardSizes.add(
            Size(minWidth + (widthGap / _stackNum) * i, minHeight + (heightGap / _stackNum) * i));
      }

      switch (orientation) {
        case AmassOrientation.BOTTOM:
          _cardAligns.add(Alignment(0.0, (0.5 / (_stackNum - 1)) * (stackNum - i)));
          break;
        case AmassOrientation.TOP:
          _cardAligns.add(Alignment(0.0, (-0.5 / (_stackNum - 1)) * (stackNum - i)));
          break;
        case AmassOrientation.LEFT:
          _cardAligns.add(Alignment((-0.5 / (_stackNum - 1)) * (stackNum - i), 0.0));
          break;
        case AmassOrientation.RIGHT:
          _cardAligns.add(Alignment((0.5 / (_stackNum - 1)) * (stackNum - i), 0.0));
          break;
      }
    }
  }
}

class _QuizSwipeCardState extends State<QuizSwipeCard> with TickerProviderStateMixin {
  Alignment frontCardAlign;
  AnimationController _animationController;
  int _currentFront;
  static int _trigger; // 0: no trigger; -1: trigger left; 1: trigger right

  Widget _buildCard(BuildContext context, int realIndex) {
    if (realIndex < 0) {
      return Container();
    }

    // If > 2 answers block horizontal movement
    if (widget._allQuiz.isNotEmpty && widget._allQuiz[widget._totalNum - realIndex - 1 < 0 ? 0 : widget._totalNum - realIndex - 1].answers.length > 2){
      widget._allowHorizontalMovement = false;
    } else {
      widget._allowHorizontalMovement = true;
    }

    int index = realIndex - _currentFront;

    if (index == widget._stackNum - 1) {
      return Align(
        alignment: _animationController.status == AnimationStatus.forward
            ? frontCardAlign = CardAnimation.frontCardAlign(
                    _animationController,
                    frontCardAlign,
                    _cardAligns[widget._stackNum - 1],
                    widget._swipeEdge,
                    widget._swipeUp,
                    widget._swipeDown)
                .value
            : frontCardAlign,
        child: Transform.rotate(
            angle: (pi / 180.0) *
                (_animationController.status == AnimationStatus.forward
                    ? CardAnimation.frontCardRota(_animationController, frontCardAlign.x).value
                    : frontCardAlign.x),
            child: SizedBox.fromSize(
              // Additional height for floating buttons
              size: Size(_cardSizes[index].width + dimensions.dim20(),
                  _cardSizes[index].height + dimensions.dim20()),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  SizedBox.fromSize(
                      size: _cardSizes[index],
                      child:
                      widget._cardBuilder(context, widget._totalNum - realIndex - 1)),

                  // Like
                  Positioned(
                    right: 0,
                    top: 0,
                    child: widget.likeButton,
                  ),

                  // Dislike
                  Positioned(
                    left: 0,
                    top: 0,
                    child: widget.dislikeButton,
                  ),
                ],
              ),
            )),
      );
    }

    return Align(
      alignment: _animationController.status == AnimationStatus.forward &&
              (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0)
          ? CardAnimation.backCardAlign(
                  _animationController, _cardAligns[index], _cardAligns[index + 1])
              .value
          : _cardAligns[index],
      child: SizedBox.fromSize(
        size: _animationController.status == AnimationStatus.forward &&
                (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0)
            ? CardAnimation.backCardSize(
                    _animationController, _cardSizes[index], _cardSizes[index + 1])
                .value
            : _cardSizes[index],
        child: widget._cardBuilder(context, widget._totalNum - realIndex - 1),
      ),
    );
  }

  List<Widget> _buildCards(BuildContext context) {
    List<Widget> cards = List();
    for (int i = _currentFront; i < _currentFront + widget._stackNum; i++) {
      cards.add(_buildCard(context, i));
    }

    // Was wrapped with SizedBox.expand
    cards.add(SizedBox.expand(
      child: GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          setState(() {
            if (widget._allowVerticalMovement) {
              frontCardAlign = Alignment(
                  frontCardAlign.x + details.delta.dx * 20 / MediaQuery.of(context).size.width,
                  frontCardAlign.y + details.delta.dy * 30 / MediaQuery.of(context).size.height);

              if (widget.swipeUpdateCallback != null)
                widget.swipeUpdateCallback(details, frontCardAlign);
            } else if (widget._allowHorizontalMovement) {
              frontCardAlign = Alignment(
                  frontCardAlign.x + details.delta.dx * 10 / MediaQuery.of(context).size.width, 0);

              if (widget.swipeUpdateCallback != null)
                widget.swipeUpdateCallback(details, frontCardAlign);
            }
          });
        },
        onPanEnd: (DragEndDetails details) {
          if (widget.onDragEnd != null) widget.onDragEnd();
          animateCards(0);
        },
      ),
    ));
    return cards;
  }

  animateCards(int trigger) {
    if (_animationController.isAnimating || _currentFront + widget._stackNum == 0) {
      return;
    }
    _trigger = trigger;
    _animationController.stop();
    _animationController.value = 0.0;
    _animationController.forward();
  }

  void triggerSwap(int trigger) {
    animateCards(trigger);
  }

  // support for asynchronous data events
  @override
  void didUpdateWidget(covariant QuizSwipeCard oldWidget) {
    if (widget._totalNum != oldWidget._totalNum) {
      _initState();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() {
    _currentFront = widget._totalNum - widget._stackNum;

    frontCardAlign = _cardAligns[_cardAligns.length - 1];
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: widget._animDuration));
    _animationController.addListener(() => setState(() {}));
    _animationController.addStatusListener((AnimationStatus status) {
      int index = widget._totalNum - widget._stackNum - _currentFront;
      if (status == AnimationStatus.completed) {
        CardSwipeOrientation orientation;
        if (frontCardAlign.x < -widget._swipeEdge)
          orientation = CardSwipeOrientation.LEFT;
        else if (frontCardAlign.x > widget._swipeEdge)
          orientation = CardSwipeOrientation.RIGHT;
        else if (frontCardAlign.y < -widget._swipeEdgeVertical)
          orientation = CardSwipeOrientation.UP;
        else if (frontCardAlign.y > widget._swipeEdgeVertical)
          orientation = CardSwipeOrientation.DOWN;
        else {
          frontCardAlign = _cardAligns[widget._stackNum - 1];
          orientation = CardSwipeOrientation.RECOVER;
        }
        if (widget.swipeCompleteCallback != null && widget._allowHorizontalMovement) widget.swipeCompleteCallback(orientation, index);
        if (orientation != CardSwipeOrientation.RECOVER) changeCardOrder();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.cardController?.addListener((trigger) => triggerSwap(trigger));

    return Stack(
      children: _buildCards(context),
    );
  }

  changeCardOrder() {
    setState(() {
      _currentFront--;
      frontCardAlign = _cardAligns[widget._stackNum - 1];
    });
  }
}

typedef Widget CardBuilder(BuildContext context, int index);

enum CardSwipeOrientation { LEFT, RIGHT, RECOVER, UP, DOWN }

/// swipe card to [CardSwipeOrientation.LEFT] or [CardSwipeOrientation.RIGHT]
/// , [CardSwipeOrientation.RECOVER] means back to start.
typedef CardSwipeCompleteCallback = void Function(CardSwipeOrientation orientation, int index);

/// [DragUpdateDetails] of swiping card.
typedef CardDragUpdateCallback = void Function(DragUpdateDetails details, Alignment align);

enum AmassOrientation { TOP, BOTTOM, LEFT, RIGHT }

class CardAnimation {
  static Animation<Alignment> frontCardAlign(AnimationController controller, Alignment beginAlign,
      Alignment baseAlign, double swipeEdge, bool swipeUp, bool swipeDown) {
    double endX, endY;

    if (_QuizSwipeCardState._trigger == 0) {
      endX = beginAlign.x > 0
          ? (beginAlign.x > swipeEdge ? beginAlign.x + 10.0 : baseAlign.x)
          : (beginAlign.x < -swipeEdge ? beginAlign.x - 10.0 : baseAlign.x);
      endY = beginAlign.x > 3.0 || beginAlign.x < -swipeEdge ? beginAlign.y : baseAlign.y;

      if (swipeUp || swipeDown) {
        if (beginAlign.y < 0) {
          if (swipeUp) endY = beginAlign.y < -swipeEdge ? beginAlign.y - 10.0 : baseAlign.y;
        } else if (beginAlign.y > 0) {
          if (swipeDown) endY = beginAlign.y > swipeEdge ? beginAlign.y + 10.0 : baseAlign.y;
        }
      }
    } else if (_QuizSwipeCardState._trigger == -1) {
      endX = beginAlign.x - swipeEdge;
      endY = beginAlign.y + 0.5;
    } else {
      endX = beginAlign.x + swipeEdge;
      endY = beginAlign.y + 0.5;
    }
    return AlignmentTween(begin: beginAlign, end: Alignment(endX, endY))
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  static Animation<double> frontCardRota(AnimationController controller, double beginRot) {
    return Tween(begin: beginRot, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  static Animation<Size> backCardSize(
      AnimationController controller, Size beginSize, Size endSize) {
    return SizeTween(begin: beginSize, end: endSize)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }

  static Animation<Alignment> backCardAlign(
      AnimationController controller, Alignment beginAlign, Alignment endAlign) {
    return AlignmentTween(begin: beginAlign, end: endAlign)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
  }
}

typedef TriggerListener = void Function(int trigger);

class CardController {
  TriggerListener _listener;

  Future<void> triggerLeft() async {
    if (_listener != null) {
      _listener(-1);
    }
  }

  Future<void> triggerRight() async {
    if (_listener != null) {
      _listener(1);
    }
  }

  void addListener(listener) {
    _listener = listener;
  }

  void removeListener() {
    _listener = null;
  }
}
