import 'package:flame/components.dart';
import 'dart:math';

class GoalkeeperComponent extends SpriteComponent with HasGameRef {
  double moveDirection = 1;
  final double speed = 100;

  GoalkeeperComponent() : super(size: Vector2(64, 64));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('goalkeeper.png');
    position = Vector2(gameRef.size.x / 2, 120);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += moveDirection * speed * dt;
    if (position.x < 80 || position.x > gameRef.size.x - 80) {
      moveDirection *= -1;
    }
  }
}
