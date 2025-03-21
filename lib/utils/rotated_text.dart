import 'dart:math' as math;

import 'package:flutter/painting.dart';

extension RotatedTextExt on Canvas {
  /// [angle] is in radians. Set `isInDegrees = true` if it is in degrees.
  void drawRotatedText({
    required Offset pivot,
    required TextPainter textPainter,
    required double angle,
    bool isInDegrees = false,
    Alignment alignment = Alignment.center,
  }) {
    //
    // Convert angle from degrees to radians
    angle = isInDegrees ? angle * math.pi / 180 : angle;

    // Calculate delta. Delta is the top left offset with reference
    // to which the main text will paint. The centre of the text will be
    // at the given pivot unless [alignment] is set.
    final w = textPainter.width;
    final h = textPainter.height;
    final delta = pivot.translate(
        -w / 2 + w / 2 * alignment.x, -h / 2 + h / 2 * alignment.y);

    // Rotate the text about pivot
    save();
    translate(pivot.dx, pivot.dy);
    rotate(angle);
    translate(-pivot.dx, -pivot.dy);
    textPainter.paint(this, delta);
    restore();
  }
}
