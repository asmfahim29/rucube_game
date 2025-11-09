import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

enum ShotType { power, finesse, chip }

class FootballComponent extends BodyComponent {
  final Vector2 position;
  bool isInAir = false;
  bool _canShoot = true;

  FootballComponent({required this.position});

  static const double _radius = 0.35;
  static const double _maxUpwardSpeed = 15;
  static const Duration _cooldown = Duration(milliseconds: 600);

  @override
  Body createBody() {
    final shape = CircleShape()..radius = _radius;

    final fixtureDef = FixtureDef(shape)
      ..density = 0.5
      ..friction = 0.2
      ..restitution = 0.6;

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.dynamic,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Apply a shooting impulse in direction with power
  void shoot(Vector2 direction, double power, ShotType type) {
    if (!_canShoot || isInAir) return;
    _canShoot = false;

    Future.delayed(_cooldown, () => _canShoot = true);

    isInAir = true;

    final impulse = direction.normalized() * power;
    body.applyLinearImpulse(impulse);

    // Clamp vertical velocity (avoid infinite upward bug)
    final v = body.linearVelocity;
    if (v.y < -_maxUpwardSpeed) {
      body.linearVelocity = Vector2(v.x, -_maxUpwardSpeed);
    }
  }

  void resetPosition(Vector2 newPos) {
    body.setTransform(newPos, 0);
    body.linearVelocity = Vector2.zero();
    isInAir = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Detect when ball lands
    if (isInAir && body.linearVelocity.y.abs() < 0.2) {
      isInAir = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset.zero, _radius * 20, paint);
  }
}