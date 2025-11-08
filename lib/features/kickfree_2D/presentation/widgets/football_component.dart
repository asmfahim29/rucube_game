import 'package:flame/components.dart';

class FootballComponent extends SpriteComponent with HasGameRef {
  Vector2 velocity = Vector2.zero();
  final double friction = 0.98;

  FootballComponent() : super(size: Vector2(32, 32));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('ball.png');
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
  }

  void kick(Vector2 direction, double power) {
    velocity = direction.normalized() * (power / 10);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    velocity *= friction;

    // Stop the ball when speed is low
    if (velocity.length < 1) velocity = Vector2.zero();
  }

  void reset() {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
    velocity = Vector2.zero();
  }
}
