import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class RolodexAnimation extends StatefulWidget {
  RolodexAnimation({
    Key key,
    this.titles,
    this.containerHeight = 150.0,
    this.textStyle,
    this.shouldAnimate = true,
  }) : super(key: key);
  final List<String> titles;
  final double containerHeight;
  final TextStyle textStyle;
  final bool shouldAnimate;

  @override
  _RolodexAnimationState createState() => _RolodexAnimationState();
}

class _RolodexAnimationState extends State<RolodexAnimation>
    with TickerProviderStateMixin {
  static const _durationInMilliseconds = 1500;
  int _currentTitleIndex = 0;
  int _nextTitleIndex = 1;
  AnimationController _controller;
  Animation _rotationAnimation;
  Animation _slightRotationAnimation;
  Animation _fadeInAnimation;
  Animation _fadeOutAnimation;
  Timer _timer;
  static Color _textColor = Colors.black54;

  Color _cardColor = Colors.white;
  final TextStyle _defaultTextStyle = TextStyle().copyWith(
    color: _textColor,
    fontSize: 36.0,
  );

  @override
  void initState() {
    if (widget.shouldAnimate) {
      _timer = Timer.periodic(
          const Duration(milliseconds: _durationInMilliseconds), (_) {
        if (_currentTitleIndex == widget.titles.length - 1) {
          _currentTitleIndex = 0;
          Future.delayed(Duration(milliseconds: 150))
            ..then((_) {
              if (mounted) {
                setState(() {
                  _nextTitleIndex = 1;
                });
              }
            });
        } else {
          if (mounted) {
            setState(() {
              _currentTitleIndex++;
            });
          }
          Future.delayed(Duration(milliseconds: 150))
            ..then((_) {
              if (_nextTitleIndex == widget.titles.length - 1) {
                if (mounted) {
                  setState(() {
                    _nextTitleIndex = 0;
                  });
                }
              } else {
                if (mounted) {
                  setState(() {
                    _nextTitleIndex++;
                  });
                }
              }
            });
        }
      });
    }
    _controller = AnimationController(
      duration: const Duration(milliseconds: _durationInMilliseconds),
      vsync: this,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {}
        if (status == AnimationStatus.dismissed) {}
      })
      ..addListener(() {});
    if (widget.shouldAnimate) {
      _controller.repeat();
    }
    _rotationAnimation = Tween(begin: 0.000000001, end: (3 * math.pi) / 2)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: Curves.easeIn),
    ));
    _fadeOutAnimation = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1, 0.3, curve: Curves.easeOut),
    ));
    _slightRotationAnimation =
        Tween(begin: (19 * math.pi) / 12, end: 2 * math.pi)
            .animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    _fadeInAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: Interval(0.1, 0.3, curve: Curves.easeOut)),
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildContentBody(context),
    );
  }

  _buildContentBody(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        String title = '';
        String nextTitle = widget.titles[_nextTitleIndex];
        if (_rotationAnimation.value >= math.pi / 2 &&
            _rotationAnimation.value <= (3 * math.pi) / 2) {
          title = '';
        } else {
          if (_controller.value > 0 && _controller.value < 0.02) {
            title = nextTitle;
          } else {
            title = widget.titles[_currentTitleIndex];
          }
        }
        return Stack(
          children: <Widget>[
            _buildNextCard(nextTitle),
            _buildFallingCard(title)
          ],
        );
      },
    );
  }

  _buildNextCard(String title) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_slightRotationAnimation.value)
        ..rotateY(0.0),
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Container(
              height: widget.containerHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        title,
                        style: widget.textStyle ?? _defaultTextStyle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildFallingCard(String title) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_rotationAnimation.value)
        ..rotateY(0.0),
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _fadeOutAnimation,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Container(
              height: widget.containerHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: FadeTransition(
                        opacity: _fadeOutAnimation,
                        child: Text(
                          title,
                          style: widget.textStyle ?? _defaultTextStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
