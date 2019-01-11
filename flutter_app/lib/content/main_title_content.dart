import 'dart:math' as math;
import 'package:example_flutter/models/normalization_multipliers.dart';
import 'package:flutter/material.dart';

class MainTitleContent extends StatefulWidget {
  MainTitleContent({
    Key key,
    Map contentMap,
    this.title,
    this.shouldAnimate = true,
    @required this.normMultis,
  })  : lineHeight = contentMap['line_height'],
        scrollTo = contentMap['scroll_to'],
        wordList = contentMap['word_list'],
        super(key: key);

  final String title;
  final bool shouldAnimate;
  final double lineHeight;
  final double scrollTo;
  final List wordList;
  final NormalizationMultipliers normMultis;

  @override
  _MainTitleContentState createState() => _MainTitleContentState();
}

class _MainTitleContentState extends State<MainTitleContent>
    with TickerProviderStateMixin {
  static const _itemCount = 10000;
  final _scrollController = ScrollController();

  AnimationController _flutterLiveController;
  Animation<Offset> _flutterLiveSlideTransition;
  Animation<double> _flutterLiveScaleTransition;
  Animation<double> _flutterLiveGlitchAnimation;

  static const _defaultFontSize = 240.0;
  int _wordIndex = 0;

  @override
  void initState() {
    _configureAnimations();
    super.initState();
  }

  @override
  void dispose() {
    _flutterLiveController?.dispose();
    super.dispose();
  }

  Future _configureAnimations() async {
    _flutterLiveController =
        AnimationController(duration: const Duration(seconds: 20), vsync: this);
    _flutterLiveSlideTransition = Tween<Offset>(
            begin: const Offset(0.0, 0.0), end: const Offset(0.1, 0.1))
        .animate(CurvedAnimation(
            parent: _flutterLiveController, curve: Curves.linear));
    _flutterLiveScaleTransition = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _flutterLiveController, curve: Curves.linear));
    _flutterLiveGlitchAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
            parent: _flutterLiveController,
            curve: Interval(
              0.98,
              0.99,
              curve: SawTooth(3),
            )));
    if (widget.shouldAnimate) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(widget.scrollTo,
            duration: const Duration(minutes: 60), curve: Curves.linear);
      }
      _playAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: _buildContentBody(context));
  }

  Widget _buildContentBody(BuildContext context) {
    double normWidthMulti = widget.normMultis.width;
    double normHeightMulti = widget.normMultis.height;
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0.0,
          top: 0.0,
          child: Container(
            width: normWidthMulti * 800,
            height: normHeightMulti * 600,
            color: Color(0xFFBFE6F3),
          ),
        ),
        Positioned(
          left: normWidthMulti * 500,
          top: 0.0,
          bottom: 0.0,
          right: 0.0,
          child: IgnorePointer(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: _itemCount,
              itemBuilder: (context, index) {
                Widget child;
                final adjustedFontSize =
                    _defaultFontSize * normWidthMulti * 0.75;
                child = WelcomeCell(
                  shouldAnimate: widget.shouldAnimate,
                  lineHeight: widget.lineHeight,
                  adjustedFontSize: adjustedFontSize,
                  nextWord: getNextWord,
                );
                return Container(
                  child: child,
                );
              },
            ),
          ),
        ),
        _buildFlutterLiveContent(context, normWidthMulti, normHeightMulti),
      ],
    );
  }

  Widget _buildFlutterLiveContent(
      BuildContext context, double normWidthMulti, double normHeightMulti) {
    return Positioned(
      left: normWidthMulti * 700,
      right: normWidthMulti * 400,
      bottom: normHeightMulti * 150,
      child: AnimatedBuilder(
        animation: _flutterLiveScaleTransition,
        builder: (context, child) {
          return child;
        },
        child: SlideTransition(
          position: _flutterLiveSlideTransition,
          child: FadeTransition(
            opacity: _flutterLiveGlitchAnimation,
            child: ScaleTransition(
              scale: _flutterLiveScaleTransition,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 35.0, top: 75.0, right: 30.0, bottom: 20.0),
                  color: Color(0xFF1B364F),
                  child: RichText(
                    maxLines: 2,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Flutter\nLive',
                            style: TextStyle().copyWith(
                                color: Colors.white,
                                height: widget.lineHeight,
                                fontFamily: 'GoogleSans',
                                fontSize: _defaultFontSize *
                                    _flutterLiveScaleTransition.value)),
                        TextSpan(
                            text: ' ‘18',
                            style: TextStyle().copyWith(
                                color: Color(0xFF13B9FD),
                                height: widget.lineHeight,
                                fontFamily: 'GoogleSans',
                                fontSize: _defaultFontSize *
                                    _flutterLiveScaleTransition.value)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String getNextWord() {
    String word = widget.wordList[_wordIndex % widget.wordList.length];
    _wordIndex++;
    return word;
  }

  void _playAnimation() async {
    try {
      if (mounted) _flutterLiveController?.forward();
      _flutterLiveController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _flutterLiveController.reset();
        } else if (status == AnimationStatus.dismissed) {
          if (mounted) _flutterLiveController?.forward();
        }
      });
    } on TickerCanceled {
      print('ticker was cancelled');
    }
  }
}

typedef _StringCallback = String Function();

class WelcomeCell extends StatefulWidget {
  final double lineHeight;
  final double adjustedFontSize;
  final bool shouldAnimate;
  final _StringCallback nextWord;

  const WelcomeCell({
    Key key,
    @required this.lineHeight,
    @required this.adjustedFontSize,
    @required this.shouldAnimate,
    @required this.nextWord,
  }) : super(key: key);

  @override
  _WelcomeCellState createState() => _WelcomeCellState();
}

class _WelcomeCellState extends State<WelcomeCell>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  String _currentText;

  @override
  void initState() {
    super.initState();
    _currentText = widget.nextWord();
    _animationController = AnimationController(
        duration: Duration(milliseconds: 4000 + math.Random().nextInt(10000)),
        vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            _animationController.reverse();
          }
        } else if (status == AnimationStatus.dismissed) {
          if (mounted) {
            setState(() {
              _currentText = widget.nextWord();
            });
            _animationController.forward();
          }
        }
      });
    if (mounted && widget.shouldAnimate) {
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glitchAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.35, 0.352, curve: SawTooth(1))));
    final flutterTextWidget = Text(
      'Flutter',
      maxLines: 1,
      overflow: TextOverflow.fade,
      style: TextStyle().copyWith(
          color: const Color(0xFF13B9FD),
          height: widget.lineHeight,
          fontFamily: 'GoogleSans',
          fontSize: widget.adjustedFontSize),
    );

    final List<Widget> letters = [];
    final letterArray = _currentText.split('');
    final minRangeValue = 0.37;
    final maxRangeValue = 0.47;
    for (int i = 0; i < letterArray.length; i++) {
      final rndDouble = minRangeValue +
          (maxRangeValue - minRangeValue) *
              math.Random(math.Random().nextInt(1000)).nextDouble();
      final letter = letterArray[i];
      final start = rndDouble;

      final endingValueForBlinkAnimation = 2;
      final blinkAnimation = IntTween(
              begin: 0, end: endingValueForBlinkAnimation)
          .animate(CurvedAnimation(
              parent: _animationController,
              curve:
                  Interval(start, maxRangeValue, curve: Curves.fastOutSlowIn)));
      Widget letterWidget;
      letterWidget = AnimatedBuilder(
        animation: blinkAnimation,
        builder: (context, child) {
          Color textColor;
          if (blinkAnimation.value == 0) {
            textColor = Colors.transparent;
          } else if (blinkAnimation.value == endingValueForBlinkAnimation) {
            textColor = const Color(0xFF13B9FD);
          } else if (blinkAnimation.value % 2 == 0) {
            textColor = Colors.transparent;
          } else {
            textColor = Colors.blue;
          }
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              child: Text(
                letter,
                overflow: TextOverflow.fade,
                maxLines: 1,
                style: TextStyle().copyWith(
                  color: textColor,
                  height: widget.lineHeight,
                  fontFamily: 'GoogleSans',
                  fontSize: widget.adjustedFontSize,
                ),
              ),
            ),
          );
        },
      );
      letters.add(letterWidget);
    }
    return Stack(
      children: <Widget>[
        // Wrap in fade transition for exit
        FadeTransition(
          opacity: glitchAnimation,
          child: flutterTextWidget,
        ),
        Row(children: letters, mainAxisSize: MainAxisSize.min),
      ],
    );
  }
}
