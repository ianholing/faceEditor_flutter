import 'dart:ui';

import 'package:flutter/cupertino.dart';

class DrawLayer {
  Color color;
  List<List<Offset>> path = new List<List<Offset>>();

  DrawLayer(this.color, this.path);
}