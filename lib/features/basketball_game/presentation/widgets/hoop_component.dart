import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/score_ball_anime_widget.dart';

import 'basketball_game_logic_widget.dart';

class HoopComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  bool moveRight = true;
  bool isAnimating = false;
  double animationProgress = 0.0;

  HoopComponent() : super(size: Vector2(90, 90));
  late Sprite ballSprite;
  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('hoop.png');
    position = Vector2((game.size.x - size.x) / 2, 100);
    final image = await game.images.load('basketball.png');
    ballSprite = Sprite(image);
  }


  @override
  void update(double dt) {
    super.update(dt);

    const speed = 80;
    if (moveRight) {
      position.x += speed * dt;
      if (position.x + size.x > game.size.x - 20) moveRight = false;
    } else {
      position.x -= speed * dt;
      if (position.x < 20) moveRight = true;
    }

    // FIX 3: Update score animation
    if (isAnimating) {
      animationProgress += dt * 2.5; // Animation speed
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
      final startY = 0.0;
      final endY = size.y + 30;

      final easedProgress = _easeInQuad(animationProgress);
      final ballY = startY + (endY - startY) * easedProgress;

      // Ball size shrinks slightly as it goes through
      final ballSize = 20 - (5 * easedProgress);

      // Define position and size for rendering the image
      final renderSize = Vector2.all(ballSize * 2);
      final renderPosition = Vector2(centerX - ballSize, ballY - ballSize);

      // Draw image (with fading opacity if desired)
      ballSprite.render(
        canvas,
        position: renderPosition,
        size: renderSize,
        overridePaint: Paint()
          ..color = Colors.white.withOpacity(1.0 - (easedProgress * 0.5)),
      );

      // Optional trail (you can use another faded draw or shadow image)
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
  // Easing function for smooth animation
  double _easeInQuad(double t) {
    return t * t;
  }

  bool checkScore(Vector2 ballPosition) {
    // Score zone detection
    return (ballPosition.y > position.y + 10 &&
        ballPosition.y < position.y + 40 &&
        ballPosition.x > position.x + 20 &&
        ballPosition.x < position.x + size.x - 20);
  }

  // FIX 3: Trigger the score animation
  void triggerScoreAnimation() {
    isAnimating = true;
    animationProgress = 0.0;
  }

}



