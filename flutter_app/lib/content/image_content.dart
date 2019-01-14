import 'dart:io';

import 'package:flutter_slides/models/slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slides/utils/image_utils.dart' as ImageUtils;

class ImageContent extends StatelessWidget {
  final String assetPath;
  final String filePath;
  final BoxFit fit;
  final bool evict;

  ImageContent({Key key, Map contentMap})
      : this.assetPath = contentMap['asset'],
        this.filePath = contentMap['file'],
        this.fit = ImageUtils.boxFitFromString(contentMap['fit']),
        this.evict = contentMap['evict'] ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      if (evict) {
        Image.asset(assetPath).image.evict();
      }
      final Image image = Image.asset(assetPath, fit: fit);
      return image;
    } else {
      final root = loadedSlides.externalFilesRoot;
      if (evict) {
        FileImage(File('$root/$filePath')).evict();
      }
      final Image image = Image.file(
        File('$root/$filePath'),
        fit: fit,
      );
      return image;
    }
  }
}
