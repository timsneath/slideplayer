import 'package:flutter/material.dart';

Map<String, BoxFit> _boxFitMap = {
  'cover': BoxFit.cover,
  'contain': BoxFit.contain,
};

BoxFit boxFitFromString(String string) {
  return _boxFitMap[string ?? ''] ?? BoxFit.contain;
}
