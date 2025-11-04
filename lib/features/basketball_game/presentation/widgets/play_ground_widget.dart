import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/basket_ball_constants.dart';

class PlaygroundBoundary extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final boundaryPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, kCanvasSize.width, kCanvasSize.height),
      boundaryPaint,
    );
  }
}

class Audience extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final audiencePaint = Paint()..color = Colors.white;
    // Simple rectangles for audience seats, can use images as well
    for (int i = 0; i < 10; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * 100.0, kCanvasSize.height - 100, 80, 50),
        audiencePaint,
      );
    }
  }
}