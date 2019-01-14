import 'dart:convert';
import 'dart:io';

import 'package:flutter_slides/models/slides.dart';
import 'package:flutter/material.dart';
import 'package:lottie_flutter/lottie_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class LottieContent extends StatefulWidget {
  final String compositionAssetPath;
  final String compositionFilePath;

  LottieContent({
    Key key,
    @required Map contentMap,
  })  : this.compositionAssetPath = contentMap['asset'],
        this.compositionFilePath = contentMap['file'],
        super(key: key);
  @override
  _LottieContentState createState() => _LottieContentState();
}

class _LottieContentState extends State<LottieContent>
    with SingleTickerProviderStateMixin {
  LottieComposition _composition;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1),
      vsync: this,
    );
    _controller.addListener(() {});
    loadLottieComposition().then((composition) {
      setState(() {
        _composition = composition;
        _controller.duration = Duration(milliseconds: _composition.duration);
        _controller.repeat();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(LottieContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadLottieComposition().then((composition) {
      setState(() {
        _composition = composition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_composition == null) {
      return Container();
    }
    return LayoutBuilder(builder: (context, constraints) {
      if (_composition == null) {
        return Container();
      }
      Size size;
      if (constraints.biggest.width <= 0.01 ||
          constraints.biggest.height <= 0.01) {
        size = Size.zero;
      } else if (_composition.bounds.size.width >= _composition.bounds.height) {
        // Stretch to largest width possible and aspect fit height
        double aspectRatioMultiplier =
            _composition.bounds.size.height / _composition.bounds.size.width;
        double width = constraints.biggest.width;
        double height = width * aspectRatioMultiplier;
        size = Size(width, height);
        if (height > constraints.biggest.height) {
          double aspectRatioMultiplier =
              _composition.bounds.size.width / _composition.bounds.size.height;
          double height = constraints.biggest.height;
          double width = height * aspectRatioMultiplier;
          size = Size(width, height);
        }
      } else {
        // Stretch to largest height possible and aspect fit width
        double aspectRatioMultiplier =
            _composition.bounds.size.width / _composition.bounds.size.height;
        double height = constraints.biggest.height;
        double width = height * aspectRatioMultiplier;
        size = Size(width, height);
        if (width > constraints.biggest.width) {
          double aspectRatioMultiplier =
              _composition.bounds.size.height / _composition.bounds.size.width;
          double width = constraints.biggest.width;
          double height = width * aspectRatioMultiplier;
          size = Size(width, height);
        }
      }
      return Center(
        child: Container(
          child: Lottie(
            size: size,
            composition: _composition,
            controller: _controller,
            coerceDuration: false,
          ),
        ),
      );
    });
  }

  Future<LottieComposition> loadLottieComposition() async {
    if (widget.compositionAssetPath != null) {
      return await loadAsset(widget.compositionAssetPath);
    } else {
      return await loadFile(widget.compositionFilePath);
    }
  }

  Future<LottieComposition> loadAsset(String assetName) async {
    return await rootBundle
        .loadString(assetName)
        .then<Map<String, dynamic>>((String data) => json.decode(data))
        .then((Map<String, dynamic> map) => new LottieComposition.fromMap(map));
  }

  Future<LottieComposition> loadFile(String filePath) async {
    return await File('${loadedSlides.externalFilesRoot}/$filePath')
        .readAsString()
        .then<Map<String, dynamic>>((String data) => json.decode(data))
        .then((Map<String, dynamic> map) => new LottieComposition.fromMap(map));
  }
}
