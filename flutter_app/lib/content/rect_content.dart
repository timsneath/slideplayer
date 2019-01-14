import 'package:flutter/material.dart';
import 'package:flutter_slides/utils/color_utils.dart' as ColorUtils;

class RectContent extends StatelessWidget {
  final Color fillColor;
  RectContent({Key key, Map contentMap})
      : this.fillColor = ColorUtils.colorFromString(contentMap['fill']),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(color: fillColor);
  }
}
