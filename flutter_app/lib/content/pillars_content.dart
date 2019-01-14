import 'dart:io';

import 'package:flutter_slides/models/normalization_multipliers.dart';
import 'package:flutter_slides/models/slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slides/utils/color_utils.dart' as ColorUtils;
import 'package:flutter_slides/utils/image_utils.dart' as ImageUtils;

enum _PillarsStage { collapsed, beautiful, fast, productive, open }

class _PositionData {
  final double top;
  final double left;
  final double width;
  final double height;

  _PositionData.fromMap(Map map)
      : this.top = map['top'],
        this.left = map['left'],
        this.width = map['width'],
        this.height = map['height'];
}

class _StagedPositions {
  _StagedPositions(this.positions);
  final Map<_PillarsStage, _PositionData> positions;
  factory _StagedPositions.fromMap(Map map) {
    final positions = Map<_PillarsStage, _PositionData>();
    positions[_PillarsStage.collapsed] =
        _PositionData.fromMap(map['collapsed']);
    positions[_PillarsStage.beautiful] =
        _PositionData.fromMap(map['beautiful']);
    positions[_PillarsStage.fast] = _PositionData.fromMap(map['fast']);
    positions[_PillarsStage.productive] =
        _PositionData.fromMap(map['productive']);
    positions[_PillarsStage.open] = _PositionData.fromMap(map['open']);
    return _StagedPositions(positions);
  }
}

class _PillarsSectionData {
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final String shellFilePath;
  final String innerFilePath;
  final String title;
  final String subtitle;
  final _StagedPositions backgroundPositions;
  final _StagedPositions titlePositions;
  final _PositionData shellImagePosition;
  final _PositionData shellImageOffsetPosition;
  final _PositionData innerImagePosition;
  final bool shellOnTop;
  final BoxFit shellFit;
  final Color shellBackgroundColor;

  _PillarsSectionData.fromMap(Map map)
      : this.backgroundColor =
            ColorUtils.colorFromString(map['background_color']),
        this.titleColor = ColorUtils.colorFromString(map['title_color']),
        this.subtitleColor = ColorUtils.colorFromString(map['subtitle_color']),
        this.shellFilePath = map['image_shell_path'],
        this.innerFilePath = map['image_innards_path'],
        this.title = map['title'],
        this.subtitle = map['subtitle'],
        this.backgroundPositions =
            _StagedPositions.fromMap(map['background_positions']),
        this.titlePositions = _StagedPositions.fromMap(map['title_positions']),
        this.shellImagePosition = _PositionData.fromMap(map['shell_image']),
        this.shellImageOffsetPosition =
            _PositionData.fromMap(map['shell_image_offset']),
        this.innerImagePosition = _PositionData.fromMap(map['inner_image']),
        this.shellOnTop = map['shell_on_top'] ?? true,
        this.shellFit = ImageUtils.boxFitFromString(map['shell_fit']),
        this.shellBackgroundColor = ColorUtils.colorFromString(
            map['inner_bg_color'],
            errorColor: Colors.transparent);
}

class PillarsContent extends StatefulWidget {
  final Map contentMap;
  final ValueNotifier<int> advancementStep;
  final NormalizationMultipliers normMultis;
  final subtitlePaddingTop;
  final _PillarsSectionData beautifulSectionData;
  final _PillarsSectionData fastSectionData;
  final _PillarsSectionData productiveSectionData;
  final _PillarsSectionData openSectionData;

  PillarsContent({
    Key key,
    @required this.contentMap,
    @required this.advancementStep,
    @required this.normMultis,
  })  : this.beautifulSectionData =
            _PillarsSectionData.fromMap(contentMap['beautiful']),
        this.fastSectionData = _PillarsSectionData.fromMap(contentMap['fast']),
        this.productiveSectionData =
            _PillarsSectionData.fromMap(contentMap['productive']),
        this.openSectionData = _PillarsSectionData.fromMap(contentMap['open']),
        this.subtitlePaddingTop = contentMap['subtile_padding_top'],
        super(key: key);

  @override
  PillarsContentState createState() {
    return new PillarsContentState();
  }
}

class PillarsContentState extends State<PillarsContent>
    with TickerProviderStateMixin {
  Animation<double> _orbAnimation;
  Animation<double> _contentAnimation;
  Animation<double> _titleFontSizeAnimation;
  Animation<double> _subtitleFontSizeAnimation;
  Animation<double> _sectionSizeAnimation;
  AnimationController _animationController;

  double orbSize;
  bool debugLocked = false;
  String orbImagePath;

  int _stage = 0;
  @override
  void initState() {
    super.initState();

    debugLocked = widget.contentMap['debug_lock'] ?? false;
    orbSize = widget.contentMap['orb_size'];
    orbImagePath = widget.contentMap['orb_image_path'];

    widget.advancementStep?.addListener(() {
      if (mounted && !debugLocked) {
        _stage++;
        if (_stage % 2 == 0) {
          _animationController.reverse(from: 1.0).then((_) {
            if (_stage < 8) {
              _animationController.forward(from: 0.0);
              _stage++;
            }
          });
        } else {
          _animationController.forward(from: 0.0);
        }
      }
    });
    _animationController = AnimationController(
        vsync: this,
        duration:
            Duration(milliseconds: widget.contentMap['controller_duration']));
    _orbAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _contentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
    _titleFontSizeAnimation = Tween<double>(
            begin: widget.contentMap['title_font_size_min'],
            end: widget.contentMap['title_font_size_max'])
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _subtitleFontSizeAnimation = Tween<double>(
            begin: widget.contentMap['subtitle_font_size_min'],
            end: widget.contentMap['subtitle_font_size_max'])
        .animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    _sectionSizeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
    if (debugLocked) {
      _animationController.value =
          widget.contentMap['debug_locked_controller_position'] ?? 1.0;
      _stage = widget.contentMap['debug_locked_stage_value'] ?? 0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                overflow: widget.contentMap['debug_overflow'] == true
                    ? Overflow.visible
                    : Overflow.clip,
                children: <Widget>[
                  _buildBackgroundSection(
                      width, height, widget.beautifulSectionData),
                  _buildBackgroundSection(
                      width, height, widget.fastSectionData),
                  _buildBackgroundSection(
                      width, height, widget.productiveSectionData),
                  _buildBackgroundSection(
                      width, height, widget.openSectionData),
                  _buildSectionTitle(
                      width, height, widget.beautifulSectionData),
                  _buildSectionTitle(width, height, widget.fastSectionData),
                  _buildSectionTitle(
                      width, height, widget.productiveSectionData),
                  _buildSectionTitle(width, height, widget.openSectionData),
                  _buildImageContent(
                      width, height, widget.beautifulSectionData),
                  _buildImageContent(width, height, widget.fastSectionData),
                  _buildImageContent(
                      width, height, widget.productiveSectionData),
                  _buildImageContent(width, height, widget.openSectionData),
                  _buildOrb(width, height),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(
      double width, double height, _PillarsSectionData sectionData) {
    _PositionData posData = positionDataForStage(sectionData.titlePositions);
    double collapsedLeft =
        sectionData.titlePositions.positions[_PillarsStage.collapsed].left;
    double collapsedTop =
        sectionData.titlePositions.positions[_PillarsStage.collapsed].top;
    double normWidthMulti = widget.normMultis.width;
    double normHeightMulti = widget.normMultis.height;
    return Positioned(
      top: collapsedTop * normHeightMulti +
          posData.top * normHeightMulti * _orbAnimation.value,
      left: collapsedLeft * normWidthMulti +
          posData.left * normWidthMulti * _orbAnimation.value,
      width: width * _sectionSizeAnimation.value,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              sectionData.title,
              style: TextStyle(
                color: sectionData.titleColor,
                fontSize: (_titleFontSizeAnimation.value) * normWidthMulti,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: widget.subtitlePaddingTop * normHeightMulti),
            ),
            Text(
              sectionData.subtitle,
              style: TextStyle(
                color: sectionData.subtitleColor
                    .withOpacity(_contentAnimation.value),
                fontSize: (_subtitleFontSizeAnimation.value) * normWidthMulti,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent(
      double width, double height, _PillarsSectionData sectionData) {
    if (sectionData == widget.beautifulSectionData && !_inBeautifulStage()) {
      return Container();
    } else if (sectionData == widget.fastSectionData && !_inFastStage()) {
      return Container();
    } else if (sectionData == widget.productiveSectionData &&
        !_inProductiveStage()) {
      return Container();
    } else if (sectionData == widget.openSectionData && !_inOpenStage()) {
      return Container();
    }
    double normWidthMulti = widget.normMultis.width;
    double normHeightMulti = widget.normMultis.height;
    final root = loadedSlides.externalFilesRoot;
    final shellFile = File('$root/${sectionData.shellFilePath}');
    final innerFile = File('$root/${sectionData.innerFilePath}');
    final top = sectionData.shellImageOffsetPosition.top *
        (1.0 - _orbAnimation.value) *
        normHeightMulti;
    final left = sectionData.shellImageOffsetPosition.left *
        (1.0 - _orbAnimation.value) *
        normWidthMulti;
    return Positioned(
      top: top +
          sectionData.shellImagePosition.top *
              _sectionSizeAnimation.value *
              normHeightMulti,
      left: left +
          width * _sectionSizeAnimation.value -
          sectionData.shellImagePosition.left *
              _sectionSizeAnimation.value *
              normWidthMulti,
      width: sectionData.shellImagePosition.width *
          _sectionSizeAnimation.value *
          normWidthMulti,
      height: sectionData.shellImagePosition.height *
          _sectionSizeAnimation.value *
          normHeightMulti,
      child: Opacity(
        opacity: _contentAnimation.value,
        child: Stack(
          children: <Widget>[
            sectionData.shellOnTop
                ? Container()
                : Image.file(shellFile, fit: BoxFit.contain),
            Positioned(
              top: sectionData.innerImagePosition.top *
                  _sectionSizeAnimation.value *
                  normHeightMulti,
              left: sectionData.innerImagePosition.left *
                  _sectionSizeAnimation.value *
                  normWidthMulti,
              height: sectionData.innerImagePosition.height *
                  _sectionSizeAnimation.value *
                  normHeightMulti,
              width: sectionData.innerImagePosition.width *
                  _sectionSizeAnimation.value *
                  normWidthMulti,
              child: Container(
                color: sectionData.shellBackgroundColor,
                child: Image.file(innerFile, fit: sectionData.shellFit),
              ),
            ),
            sectionData.shellOnTop
                ? Image.file(shellFile, fit: BoxFit.contain)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundSection(
      double width, double height, _PillarsSectionData sectionData) {
    final posData = positionDataForStage(sectionData.backgroundPositions);
    final normHeightMultiplier = widget.normMultis.height;
    final normWidthMultiplier = widget.normMultis.width;
    final top =
        sectionData.backgroundPositions.positions[_PillarsStage.collapsed].top;
    final left =
        sectionData.backgroundPositions.positions[_PillarsStage.collapsed].left;
    return Positioned(
      top: top * normHeightMultiplier +
          posData.top * _orbAnimation.value * normHeightMultiplier,
      left: left * normWidthMultiplier +
          posData.left * _orbAnimation.value * normWidthMultiplier,
      width: width * _sectionSizeAnimation.value,
      height: height * _sectionSizeAnimation.value,
      child: Container(color: sectionData.backgroundColor),
    );
  }

  Widget _buildOrb(double width, double height) {
    double topMulti;
    double leftMulti;
    if (_inBeautifulStage() || _inProductiveStage()) topMulti = height / 2.0;
    if (_inFastStage() || _inOpenStage()) topMulti = -height / 2.0;
    if (_inBeautifulStage() || _inFastStage()) leftMulti = width / 2.0;
    if (_inOpenStage() || _inProductiveStage()) leftMulti = -width / 2.0;
    double orbSize = this.orbSize * widget.normMultis.width;
    return Positioned(
      top: height / 2.0 - (orbSize / 2.0) + topMulti * _orbAnimation.value,
      left: width / 2.0 - (orbSize / 2.0) + leftMulti * _orbAnimation.value,
      width: orbSize,
      height: orbSize,
      child: Transform.scale(
        scale: 1.0 * (1.0 - _orbAnimation.value),
        alignment: Alignment.center,
        child: Opacity(
          opacity: 1.0 - _orbAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.all(Radius.circular(orbSize / 2.0)),
            ),
            child: Center(
              child: Image.file(
                File(loadedSlides.externalFilesRoot + '/' + orbImagePath),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _PositionData positionDataForStage(_StagedPositions stagedPositions) {
    if (_inBeautifulStage())
      return stagedPositions.positions[_PillarsStage.beautiful];
    if (_inFastStage()) return stagedPositions.positions[_PillarsStage.fast];
    if (_inProductiveStage())
      return stagedPositions.positions[_PillarsStage.productive];
    else
      return stagedPositions.positions[_PillarsStage.open];
  }

  bool _inBeautifulStage() => _stage == 0 || _stage == 1 || _stage == 2;
  bool _inFastStage() => _stage == 3 || _stage == 4;
  bool _inProductiveStage() => _stage == 5 || _stage == 6;
  bool _inOpenStage() => _stage == 7 || _stage == 8;
}
