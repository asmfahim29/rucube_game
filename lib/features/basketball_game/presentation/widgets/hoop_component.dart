import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/score_ball_anime_widget.dart';

import 'basketball_game_logic_widget.dart';

class HoopComponent extends SpriteComponent with HasGameReference<BasketballGame> {
  bool moveRight = true;

  HoopComponent() : super(size: Vector2(80, 80));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('hoop.png');
    position = Vector2((game.size.x - size.x) / 2, 100);
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
  }

  bool checkScore(Vector2 ballPosition) {
    // Simple hitbox zone (you can tighten this later)
    return (ballPosition.y > position.y + 10 &&
        ballPosition.y < position.y + 40 &&
        ballPosition.x > position.x + 20 &&
        ballPosition.x < position.x + size.x - 20);
  }

  void spawnScoreAnim(double x, double y) {
    add(ScoreBallAnim(Vector2(x, y)));
  }

}



