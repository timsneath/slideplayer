import 'package:example_flutter/models/slides.dart';
import 'package:example_flutter/slides/slide_presentation.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';

import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:menubar/menubar.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  // Desktop platforms are not recognized as valid targets by
  // Flutter; force a specific target to prevent exceptions.
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  setApplicationMenu([
    Submenu(label: 'File', children: [
      MenuItem(
          label: 'Open',
          onClicked: () {
            file_chooser.showOpenPanel((result, paths) {
              if (paths != null) {
                FlutterSlidesModel().loadSlidesData(paths.first);
              }
            }, allowsMultipleSelection: false);
          }),
    ]),
  ]);
  runApp(_MyApp());
}

class _MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<FlutterSlidesModel>(
      model: loadedSlides,
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'GoogleSans',
        ),
        home: SlidePresentation(),
      ),
    );
  }
}
