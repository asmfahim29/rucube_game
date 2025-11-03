import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreBallAnim extends PositionComponent with HasGameRef {
  double life = 0.35; // seconds
  final Paint p = Paint()..color = Colors.orange;
  final double startY;
  ScoreBallAnim(Vector2 startPos)
      : startY = startPos.y,
        super(position: startPos, size: Vector2.all(20), anchor: Anchor.center);

  @override
  void update(double dt) {
    life -= dt;
    // drop ~200px over lifetime
    position.y = startY + 200 * (1 - life / 0.35);
    p.color = p.color.withOpacity(life.clamp(0, 1));
    if (life <= 0) removeFromParent();
  }

  @override
  void render(Canvas c) {
    c.drawCircle(Offset.zero, 10, p);
  }
}
