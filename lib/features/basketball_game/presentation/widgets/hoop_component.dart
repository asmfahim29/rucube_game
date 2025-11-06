import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'basketball_game_logic_widget.dart';


class HoopComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  bool moveRight = true;
  bool isAnimating = false;
  double animationProgress = 0.0;

  double currentSpeed = 0.0;
  late Vector2 initialPosition; // Store initial position

  HoopComponent() : super(size: Vector2(130, 130));
  late Sprite ballSprite;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('hoop.png');
    position = Vector2((game.size.x - size.x) / 2, 150);

    // Store initial position for reset
    initialPosition = position.clone();

    final image = await game.images.load('basketball.png');
    ballSprite = Sprite(image);
  }

  void setSpeed(double speed) {
    currentSpeed = speed.abs();
    if (speed != 0 && currentSpeed > 0) {
      moveRight = speed > 0;
    }
  }

  // NEW: Reset hoop to initial state
  void resetHoop() {
    currentSpeed = 0.0;
    position = initialPosition.clone();
    moveRight = true;
    isAnimating = false;
    animationProgress = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (currentSpeed > 0) {
      if (moveRight) {
        position.x += currentSpeed * dt;
        if (position.x + size.x > game.size.x - 20) {
          moveRight = false;
        }
      } else {
        position.x -= currentSpeed * dt;
        if (position.x < 20) {
          moveRight = true;
        }
      }
    }

    if (isAnimating) {
      animationProgress += dt * 2.5;
      if (animationProgress >= 1.0) {
        isAnimating = false;
        animationProgress = 0.0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isAnimating) {
      final centerX = size.x / 2;
      const startY = 0.0;
      final endY = size.y + 30;

      final easedProgress = _easeInQuad(animationProgress);
      final ballY = startY + (endY - startY) * easedProgress;
      final ballSize = 20 - (5 * easedProgress);

      final renderSize = Vector2.all(ballSize * 2);
      final renderPosition = Vector2(centerX - ballSize, ballY - ballSize);

      ballSprite.render(
        canvas,
        position: renderPosition,
        size: renderSize,
        overridePaint: Paint()
          ..color = Colors.white.withOpacity(1.0 - (easedProgress * 0.5)),
      );

      if (easedProgress < 0.7) {
        ballSprite.render(
          canvas,
          position: Vector2(centerX - ballSize, ballY - ballSize - 10),
          size: renderSize * 0.8,
          overridePaint: Paint()
            ..color = Colors.white.withOpacity(0.3 * (1.0 - easedProgress)),
        );
      }
    }
  }

  double _easeInQuad(double t) => t * t;

  bool checkScore(Vector2 ballPosition) {
    return (ballPosition.y > position.y + 10 &&
        ballPosition.y < position.y + 40 &&
        ballPosition.x > position.x + 20 &&
        ballPosition.x < position.x + size.x - 20);
  }

  void triggerScoreAnimation() {
    isAnimating = true;
    animationProgress = 0.0;
  }
}



