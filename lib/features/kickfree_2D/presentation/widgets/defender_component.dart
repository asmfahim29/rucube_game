import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

/// Defender wall image component using Forge2D physics
class DefenderComponent extends BodyComponent {
  final Vector2 position;
  late SpriteComponent _sprite;

  bool isJumping = false;
  double jumpForce = -8.5;
  double jumpCooldown = 1.5;
  bool _canJump = true;

  DefenderComponent({required this.position});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load sprite (make sure image path exists)
    final sprite = await game.loadSprite('football/defender_idle.png');
    _sprite = SpriteComponent(
      sprite: sprite,
      size: Vector2(3, 3), // tune this depending on your image scale
      anchor: Anchor.center,
    );

    add(_sprite);
  }

  @override
  Body createBody() {
    // Adjust hitbox size according to sprite proportion
    final shape = PolygonShape()
      ..setAsBox(
        1.2, // halfWidth
        1.3, // halfHeight
        Vector2(0, -0.3), // center offset (up by 0.3 units)
        0, // angle
      );

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.3
      ..restitution = 0.1;

    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: position,
      fixedRotation: true,
      userData: this,
    );

    final body = world.createBody(bodyDef);
    body.createFixture(fixtureDef);
    return body;
  }

  /// Trigger jump motion
  void jump() {
    if (!_canJump) return;
    _canJump = false;

    body.applyLinearImpulse(Vector2(0, jumpForce));

    Future.delayed(Duration(seconds: jumpCooldown.toInt()), () {
      _canJump = true;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Sync sprite with physics body
    _sprite.position = body.position;
    _sprite.angle = body.angle;

    // Prevent falling below ground
    if (body.position.y > 25) {
      body.setTransform(Vector2(body.position.x, 24.8), 0);
      body.linearVelocity = Vector2.zero();
    }
  }
}

