import 'package:rucube_game/features/kickfree_2D/presentation/widgets/defender_component.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/stadium_component.dart';
import 'football_component.dart';
import 'kicker_component.dart';

import 'package:flame/components.dart' hide Vector2, World;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:vector_math/vector_math.dart' as v_math;
import 'package:vector_math/vector_math_64.dart' as v_math64;

extension Vector2Convert on v_math64.Vector2 {
  v_math.Vector2 toFlameVector() => v_math.Vector2(x, y);
}

class KickFree2dGameLogic extends Forge2DGame with HasCollisionDetection {
  KickFree2dGameLogic() : super(gravity: Vector2(0, 9.8), zoom: 20);

  late FootballComponent ball;
  late KickerComponent kicker;
  double _jumpTimer = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background first
    await add(StadiumBackgroundComponent());

    // Add ground
    final groundShape = EdgeShape()
      ..set(Vector2(-50, 25), Vector2(50, 25));
    final groundBody = world.createBody(BodyDef(type: BodyType.static));
    groundBody.createFixtureFromShape(groundShape);

    final defenders = [
      DefenderComponent(position: Vector2(18, 24)),
      DefenderComponent(position: Vector2(19, 24)),
      DefenderComponent(position: Vector2(20, 24)),
    ];

    await addAll(defenders);

    // Add main components
    kicker = KickerComponent(position: Vector2(10, 24));
    ball = FootballComponent(position: Vector2(13, 24));

    await addAll([kicker, ball]);

    // Camera setup
    camera.viewfinder.zoom = 20;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _jumpTimer += dt;

    if (_jumpTimer > 3) {
      for (final d in children.whereType<DefenderComponent>()) {
        d.jump();
      }
      _jumpTimer = 0;
    }
  }
}
