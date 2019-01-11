import 'package:flutter/material.dart';

class ErrorContent extends StatelessWidget {
  ErrorContent({Key key, Map contentMap}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.redAccent.withOpacity(0.25));
  }
}
