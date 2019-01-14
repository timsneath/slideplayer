import 'package:flutter_slides/models/normalization_multipliers.dart';
import 'package:flutter/material.dart';

class DesktopEmbeddingContent extends StatelessWidget {
  final NormalizationMultipliers normalizationMultipliers;
  final ValueNotifier<int> _counter = ValueNotifier(0);

  DesktopEmbeddingContent({Key key, this.normalizationMultipliers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double normWidthMulti = normalizationMultipliers.width;
    double normHeightMulti = normalizationMultipliers.height;
    double fontMulti = normalizationMultipliers.font;
    final double fabSize = 80.0 * normWidthMulti;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 0.0,
            left: 0.0,
            right: 0.0,
            height: 80.0 * normHeightMulti,
            child: Material(
              color: Colors.blue,
              elevation: 4.0,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.0 * normWidthMulti),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Flutter Desktop Embedding',
                    style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.white, fontSize: 36.0 * fontMulti),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'You have pushed the button this many times:',
                  style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: 40.0 * fontMulti,
                      ),
                ),
                AnimatedBuilder(
                  animation: _counter,
                  builder: (_, child) {
                    return Text(
                      '${_counter.value}',
                      style: Theme.of(context)
                          .textTheme
                          .display1
                          .copyWith(fontSize: 96.0 * fontMulti),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40.0 * normHeightMulti,
            right: 40.0 * normWidthMulti,
            child: Container(
              width: fabSize,
              height: fabSize,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(fabSize / 2.0),
                color: Colors.blue,
                child: InkWell(
                  onTap: () {
                    _counter.value += 1;
                  },
                  borderRadius: BorderRadius.circular(fabSize / 2.0),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      size: 30.0 * normWidthMulti,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
