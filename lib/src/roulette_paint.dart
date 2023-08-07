/// Copyright 2021 do9core
///
/// Licensed under the Apache License, Version 2.0 (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///
///    http://www.apache.org/licenses/LICENSE-2.0
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

import 'package:flutter/material.dart';
import 'package:roulette/utils/transform_entry.dart';

import 'dart:math';
import 'dart:ui' as ui;

import 'roulette_style.dart';
import 'roulette_group.dart';

/// Animated roulette core by [AnimatedWidget]
class RoulettePaint extends AnimatedWidget {
  const RoulettePaint({
    Key? key,
    required Animation<double> animation,
    required this.style,
    required this.group,
  }) : super(key: key, listenable: animation);

  final RouletteStyle style;
  final RouletteGroup group;

  Animation<double> get _rotation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: CustomPaint(
        painter: _RoulettePainter(
          rotate: _rotation.value,
          style: style,
          group: group,
        ),
      ),
    );
  }
}

class _RoulettePainter extends CustomPainter {
  _RoulettePainter({
    required this.style,
    required this.rotate,
    required this.group,
  });

  final double rotate;
  final RouletteStyle style;
  final RouletteGroup group;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();
    canvas.rotate(-pi / 2 + rotate);

    _drawBackground(canvas, radius, rect);
    _drawSections(canvas, radius);

    canvas.restore();

    _drawCenterSticker(canvas, radius);
  }

  void _drawBackground(Canvas canvas, double radius, Rect rect) {
    _paint.strokeWidth = 0;
    _paint.style = ui.PaintingStyle.fill;

    double drewSweep = 0;
    for (var i = 0; i < group.divide; i++) {
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      canvas.save();
      canvas.rotate(drewSweep);

      // Draw the section background
      _paint.color = unit.color;
      _paint.strokeWidth = 0;
      _paint.style = ui.PaintingStyle.fill;
      canvas.drawArc(rect, 0.0 * i, sweep, true, _paint);

      if (unit.image != null) {
        // Image to draw in the section.
        final image = unit.image!;

        // Draws the section background image

        // Path for this section.
        Path path = Path();
        path.addArc(rect, 0.0 * i, sweep);
        path.lineTo(0, 0);

        // Rectangle in which the section is.
        var rect2 = path.getBounds();

        // Transforms into a square (biggest)
        if (rect2.height > rect2.width) {
          rect2 = Rect.fromLTWH(rect2.left, rect2.top, rect2.height, rect2.height);
        } else {
          rect2 = Rect.fromLTWH(rect2.left, rect2.top, rect2.width, rect2.width);
        }

        // Calculates size of image in the square.
        double scaleX = (rect2.width / image.width);
        double scaleY = (rect2.height / image.height);

        // Transformation matrix to scale and rotate image in the section.
        Matrix4 matrix = composeMatrixFromOffsets(
          translate:
              Offset(style.dividerThickness / 2 - 1, rect2.top + rect2.height * 4 + style.dividerThickness / 2 + 1),
          scale: (max(scaleX, scaleY)) - 0.002,
          rotation: sweep / 2 + pi / 2,
          anchor: Offset.zero,
        );

        // Draws the section with the image.
        canvas.drawPath(
          path,
          Paint()
            ..shader = ImageShader(
              image,
              TileMode.repeated,
              TileMode.repeated,
              matrix.storage,
              filterQuality: FilterQuality.medium,
            )
            ..style = PaintingStyle.fill
            ..strokeWidth = 0,
        );
      }

      // Draw the section border
      _paint.color = style.dividerColor;
      _paint.strokeWidth = style.dividerThickness;
      _paint.style = ui.PaintingStyle.stroke;
      canvas.drawArc(rect, 0.0 * i, sweep, true, _paint);

      canvas.restore();

      drewSweep += sweep;
    }
  }

  void _drawSections(Canvas canvas, double radius) {
    double drewSweep = 0.0; // Drew sweep angle
    for (var i = 0; i < group.divide; i++) {
      // Draw each section with unit
      final unit = group.units[i];
      final sweep = 2 * pi * unit.weight / group.totalWeights;

      canvas.save();
      canvas.rotate(drewSweep + pi / 2 + sweep / 2);

      final IconData? icon = unit.icon;

      String? text = unit.text;

      if (icon != null) {
        text = String.fromCharCode(icon.codePoint);
      }

      if (text == null) {
        canvas.restore();
        continue;
      }

      final unitTextStyle = unit.textStyle ?? style.textStyle;
      final textStyle = icon != null ? unitTextStyle.copyWith(fontFamily: icon.fontFamily) : unitTextStyle;

      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
      ))
        ..pushStyle(textStyle.asUiTextStyle())
        ..addText(text);

      // Calculate chord of circle
      final chord = 2 * (radius * style.textLayoutBias) * sin(sweep / 2);

      final p = pb.build();
      p.layout(ui.ParagraphConstraints(width: chord));

      canvas.drawParagraph(
        p,
        Offset(-chord / 2, -radius * style.textLayoutBias),
      );
      canvas.restore();

      drewSweep += sweep;
    }
  }

  void _drawCenterSticker(Canvas canvas, double radius) {
    _paint.color = style.centerStickerColor;
    _paint.strokeWidth = 0;
    _paint.style = ui.PaintingStyle.fill;
    canvas.drawCircle(
      Offset.zero,
      radius * style.centerStickSizePercent,
      _paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoulettePainter oldDelegate) {
    return oldDelegate.rotate != rotate || oldDelegate.group != group || oldDelegate.style != style;
  }
}

extension _Cast on TextStyle {
  ui.TextStyle asUiTextStyle() => ui.TextStyle(
        color: color,
        decoration: decoration,
        decorationColor: decorationColor,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        textBaseline: textBaseline,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        leadingDistribution: leadingDistribution,
        locale: locale,
        background: background,
        foreground: foreground,
        shadows: shadows,
        fontFeatures: fontFeatures,
      );
}
