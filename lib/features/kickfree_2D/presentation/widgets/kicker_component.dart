import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/football_component.dart';

class KickerComponent extends BodyComponent {
  final Vector2 position;
  FootballComponent? ball;

  KickerComponent({required this.position});

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBox(0.4, 1.2, Vector2(0.0, -0.5),  0.0);

    final fixtureDef = FixtureDef(shape)
      ..density = 1.0
      ..isSensor = true;

    final bodyDef = BodyDef(
      type: BodyType.kinematic,
      position: position,
      userData: this,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  /// Prepare for shot (can be connected to joystick aiming)
  void aimAt(Vector2 target) {
    // You can rotate or face direction here
    final dir = target - body.position;
    body.setTransform(body.position, dir.angleTo(Vector2(0.0, -1.0)));
  }

  /// Perform shooting via BallComponent
  void performShot(ShotType type) {
    if (ball == null) return;

    Vector2 direction;
    double power;

    switch (type) {
      case ShotType.power:
        direction = Vector2(1.0, -0.7);
        power = 14.0;
        break;
      case ShotType.finesse:
        direction = Vector2(1.0, -0.4);
        power = 10.0;
        break;
      case ShotType.chip:
        direction = Vector2(1.0, -1.0);
        power = 12.0;
        break;
    }

    ball!.shoot(direction, power, type);
  }
}

