import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'basketball_game_logic_widget.dart';

class BallComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  Vector2 velocity = Vector2.zero();
  final double gravity = 1200;
  bool isMoving = false;
  double rotationSpeed = 0.0;

  // FIX 1: Add flag to track if ball has been shot before
  bool hasBeenShot = false;

  BallComponent() : super(size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('basketball.png');
    anchor = Anchor.center;
    position = Vector2(game.size.x / 2, game.size.y - 100);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isMoving) return;

    velocity.y += gravity * dt;
    position += velocity * dt;
    angle += rotationSpeed * dt;

    if (position.y > game.size.y + 50) {
      resetBall();
      // FIX 3: Call miss handler immediately when ball goes off screen
      game.handleMissedShot();
    }
  }

  void shoot(Offset flickVelocity) {
    // FIX 1: Ensure proper velocity calculation on first shot
    // Clamp values more aggressively and ensure minimum velocity
    final vx = (flickVelocity.dx / 6).clamp(-800.0, 800.0);
    final vy = (flickVelocity.dy / 6).clamp(-1200.0, -400.0);

    // Add minimum threshold to ensure ball always moves
    final finalVy = vy.abs() < 400 ? -400.0 : vy;

    velocity = Vector2(vx, finalVy);
    rotationSpeed = vx.sign * 5;
    isMoving = true;
    hasBeenShot = true;

    // Debug print to verify velocity
    print('Ball shot with velocity: vx=$vx, vy=$finalVy');
  }

  void resetBall() {
    isMoving = false;
    position = Vector2(game.size.x / 2, game.size.y - 100);
    velocity = Vector2.zero();
    rotationSpeed = 0.0;
    angle = 0.0; // Reset rotation angle as well
  }
}


