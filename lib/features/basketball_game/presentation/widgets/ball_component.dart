import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'basketball_game_logic_widget.dart';

class BallComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  Vector2 velocity = Vector2.zero();
  final double gravity = 1200;
  bool isMoving = false;
  double rotationSpeed = 0.0;

  BallComponent() : super(size: Vector2(40, 40));

  late final Animation _ballAnim;


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
      game.handleMissedShot();
    }
  }

  void shoot(Offset flickVelocity) {
    final vx = (flickVelocity.dx / 6).clamp(-800, 800).toDouble();
    final vy = (flickVelocity.dy / 6).clamp(-1200, -400).toDouble();
    velocity = Vector2(vx, vy);
    rotationSpeed = vx.sign * 5;
    isMoving = true;
  }

  void resetBall() {
    isMoving = false;
    position = Vector2(game.size.x / 2, game.size.y - 100);
    velocity = Vector2.zero();
    rotationSpeed = 0.0;
  }
}


