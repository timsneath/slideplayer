import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_slides/utils/color_utils.dart' as ColorUtils;
import 'package:flutter/material.dart';
import 'package:flutter_slides/models/slides.dart';

class TeamPhotosContent extends StatefulWidget {
  final Map contentMap;
  final int rowCount;
  final int columnCount;
  final Random random;
  final List<dynamic> teamPhotoFilePathList;
  final List<Color> bgColors;
  final bool shuffle;
  final bool isPreview;
  TeamPhotosContent(
      {Key key, @required this.contentMap, this.isPreview = false})
      : columnCount = contentMap['column_count'],
        rowCount = contentMap['row_count'],
        random = Random(contentMap['seed']),
        teamPhotoFilePathList = contentMap['photo_files'],
        shuffle = contentMap['shuffle_initial'] ?? false,
        bgColors = List<Color>.generate((contentMap['colors'] as List).length,
            (index) {
          return ColorUtils.colorFromString(
            contentMap['colors'][index],
            errorColor: Color(0xFF1B364F),
          );
        }),
        super(key: key);

  @override
  _TeamPhotosContentState createState() => _TeamPhotosContentState();
}

class _TeamPhotosImagePathSupplier {
  final List<dynamic> imagePaths;
  int _imagesSuppliedCount = -1;

  _TeamPhotosImagePathSupplier(
    this.imagePaths, {
    bool shuffle,
    Random random,
  }) {
    if (shuffle) {
      imagePaths.shuffle(random);
    }
  }

  String getNextImagePath() {
    _imagesSuppliedCount += 1;
    return imagePaths[_imagesSuppliedCount % imagePaths.length].toString();
  }
}

class _TeamPhotosContentState extends State<TeamPhotosContent> {
  int _imagesSuppliedCount = 0;
  final String fileRoot = loadedSlides.externalFilesRoot;

  _TeamPhotosImagePathSupplier _teamPhotosImagePathSupplier;
  @override
  void initState() {
    super.initState();
    _teamPhotosImagePathSupplier = _TeamPhotosImagePathSupplier(
      widget.teamPhotoFilePathList,
      random: widget.random,
      shuffle: widget.shuffle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(widget.columnCount, (currCol) {
        return Expanded(
          child: Row(
            children: List<Widget>.generate(widget.rowCount, (currRow) {
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.bgColors[
                        (currCol * widget.rowCount + currRow) %
                            widget.bgColors.length],
                  ),
                  child: !widget.isPreview
                      ? ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: TeamPhotoImage(
                            widget.contentMap,
                            teamPhotosImagePathSupplier:
                                _teamPhotosImagePathSupplier,
                            random: widget.random,
                          ),
                        )
                      : Container(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class TeamPhotoImage extends StatefulWidget {
  final _TeamPhotosImagePathSupplier teamPhotosImagePathSupplier;
  final Random random;
  final int minShownDuration;
  final int extraDurationMax;
  final int blinkDuration;

  TeamPhotoImage(
    Map content, {
    Key key,
    @required this.teamPhotosImagePathSupplier,
    @required this.random,
  })  : minShownDuration = content['min_shown_duration_milliseconds'] ?? 4000,
        extraDurationMax =
            content['extra_shown_duration_max_milliseconds'] ?? 2500,
        blinkDuration = content['blink_duration_milliseconds'] ?? 250,
        super(key: key);
  @override
  _TeamPhotoImageState createState() => _TeamPhotoImageState();
}

class _TeamPhotoImageState extends State<TeamPhotoImage>
    with TickerProviderStateMixin {
  final String fileRoot = loadedSlides.externalFilesRoot;
  AnimationController _animationController;
  Timer _updateTimer;
  String _nextImagePath;
  @override
  void initState() {
    _updateTimer = Timer.periodic(
        Duration(
          milliseconds: widget.minShownDuration +
              widget.random.nextInt(
                widget.extraDurationMax.clamp(1, widget.extraDurationMax),
              ),
        ), (timer) {
      if (mounted) {
        setState(() {
          _nextImagePath =
              '$fileRoot/${widget.teamPhotosImagePathSupplier.getNextImagePath()}';
          _animationController.forward(from: 0.0);
        });
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.blinkDuration),
    );
    _nextImagePath =
        '$fileRoot/${widget.teamPhotosImagePathSupplier.getNextImagePath()}';
    _animationController.forward(from: 1.0);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value.floor().toDouble(),
          child: child,
        );
      },
      child: Image.file(
        File(_nextImagePath),
        fit: BoxFit.cover,
      ),
    );
  }
}
