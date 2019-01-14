import 'package:flutter/material.dart';
import 'package:flutter_slides/utils/color_utils.dart' as ColorUtils;
import 'package:flutter_slides/utils/align_utils.dart' as AlignUtils;

class LabelContent extends StatelessWidget {
  final String text;
  final Alignment alignment;
  final TextStyle textStyle;
  final TextAlign textAlign;
  LabelContent({
    Key key,
    @required this.text,
    @required this.textStyle,
    @required this.textAlign,
    @required this.alignment,
  }) : super(key: key);

  factory LabelContent.fromContentMap({
    Map contentMap,
    double fontScaleFactor,
  }) {
    String text = contentMap['text'];
    Color fontColor = ColorUtils.colorFromString(contentMap['font_color']);
    double fontSize = (contentMap['font_size'] as num).toDouble();
    double lineHeight = (contentMap['line_height'] as num)?.toDouble();
    double letterSpacing = (contentMap['letter_spacing'] as num)?.toDouble();
    String textAlignStr = contentMap['text_align'];
    String fontFamily = contentMap['font_family'];
    bool strikeThrough = contentMap['strike_through'] ?? false;
    bool italic = contentMap['italic'] ?? false;
    TextStyle textStyle = TextStyle(
        color: fontColor,
        fontSize: (fontSize * fontScaleFactor).toDouble(),
        height: 1.0);
    if (fontFamily != null) {
      textStyle = textStyle.copyWith(fontFamily: fontFamily);
    }
    if (lineHeight != null) {
      textStyle = textStyle.copyWith(height: lineHeight);
    }
    if (strikeThrough == true) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (italic) {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
    }
    if (letterSpacing != null) {
      letterSpacing = letterSpacing * fontScaleFactor;
      textStyle = textStyle.copyWith(letterSpacing: letterSpacing);
    }
    TextAlign textAlign = TextAlign.start;
    if (textAlignStr != null) {
      if (textAlignStr == 'center')
        textAlign = TextAlign.center;
      else if (textAlignStr == 'end') textAlign = TextAlign.end;
    }
    final alignment = AlignUtils.alignmentFromString(contentMap['align']);
    return LabelContent(
      text: text,
      textStyle: textStyle,
      textAlign: textAlign,
      alignment: alignment,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Text(text, style: textStyle, textAlign: textAlign),
    );
  }
}
