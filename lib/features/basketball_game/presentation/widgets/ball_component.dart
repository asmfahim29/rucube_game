import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/hoop_component.dart';

import 'basketball_game_logic_widget.dart';

class BallComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  Vector2 velocity = Vector2.zero();
  final double gravity = 1200;
  bool isMoving = false;
  double rotationSpeed = 0.0;

  // score animation
  bool isScoring = false;
  double scoreAnimationTime = 0.0;
  Vector2? scoreStart;
  Vector2? scoreEnd;
  late HoopComponent hoop;

  BallComponent() : super(size: Vector2(50, 50));


  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('basketball.png');
    anchor = Anchor.center;
    position = Vector2(game.size.x / 2, game.size.y - 100);

    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isScoring) {
      scoreAnimationTime += dt;
      const duration = 0.6;
      final t = (scoreAnimationTime / duration).clamp(0, 1).toDouble();
      final eased = Curves.easeInOut.transform(t);

      // 🏀 Always aim toward the *current* hoop position
      final liveHoopPos = hoop.position.clone() + Vector2(hoop.size.x / 2, hoop.size.y / 1.3);

      // 🎯 Bézier curve: nice arc dropping into the hoop
      final midY = (scoreStart!.y + liveHoopPos.y) / 2 - 120; // arc height above
      final control = Vector2((scoreStart!.x + liveHoopPos.x) / 2, midY);

      // Apply quadratic Bézier interpolation
      position = Vector2(
        pow(1 - eased, 2) * scoreStart!.x +
            2 * (1 - eased) * eased * control.x +
            pow(eased, 2) * liveHoopPos.x,
        pow(1 - eased, 2) * scoreStart!.y +
            2 * (1 - eased) * eased * control.y +
            pow(eased, 2) * liveHoopPos.y,
      );

      // 🏀 Shrink & fade for realism
      final shrinkFactor = 1.0 - (0.3 * eased);
      size = Vector2.all(60 * shrinkFactor);
      opacity = 1.0 - (t * 0.5);

      // Optional: slight rotation while moving
      angle += 3 * dt;

      if (t >= 1.0) {
        isScoring = false;
        opacity = 1.0;
        size = Vector2.all(50);
        resetBall();
      }

      return;
    }


    if (!isMoving) return;

    velocity.y += gravity * dt;
    position += velocity * dt;
    angle += rotationSpeed * dt;

    if (position.y > game.size.y + 50) {
      resetBall();
      game.handleMissedShot();
    }
  }


  void shoot(Offset flickVelocity) {
    // ✅ Prevent multiple taps or mid-air shots
    if (isMoving || isScoring) return;

    final vx = (flickVelocity.dx / 6).clamp(-800, 800).toDouble();
    final vy = (flickVelocity.dy / 6).clamp(-1200, -400).toDouble();
    velocity = Vector2(vx, vy);
    rotationSpeed = vx.sign * 5;
    isMoving = true;

    debugPrint('🎯 Ball shoot velocity: vx=$vx, vy=$vy');
  }

  void resetBall() {
    isMoving = false;
    position = Vector2(game.size.x / 2, game.size.y - 100);
    velocity = Vector2.zero();
    rotationSpeed = 0.0;
  }

  // score animation method
  void animateScore(Vector2 hoopCenter) {
    isMoving = false;
    isScoring = true;
    scoreAnimationTime = 0.0;

    // Start from current position
    scoreStart = position.clone();
    // End slightly below the hoop
    scoreEnd = Vector2(hoopCenter.x, hoopCenter.y + 120);
  }
}


