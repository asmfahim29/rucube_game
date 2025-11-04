import 'dart:ui';
import 'package:flame/game.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
import 'ball_component.dart';
import 'hoop_component.dart';
import 'package:audioplayers/audioplayers.dart';

class BasketballGame extends FlameGame {
  final BasketballGameBloc bloc;
  late BallComponent ball;
  late HoopComponent hoop;
  final AudioPlayer player = AudioPlayer();
  int missedShots = 0;

  BasketballGame(this.bloc);

  @override
  Future<void> onLoad() async {
    ball = BallComponent();
    hoop = HoopComponent();
    addAll([hoop, ball]);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (ball.isMoving && hoop.checkScore(ball.position)) {
      ball.isMoving = false;
      bloc.add(Scored());
      playSound('score.mp3');
      missedShots = 0;
      ball.resetBall();
    }
  }

  void onFlick(Offset velocity) {
    if (!ball.isMoving) {
      ball.shoot(velocity);
    }
  }

  void handleMissedShot() {
    missedShots++;
    if (missedShots >= 3) {
      bloc.add(Missed());
      missedShots = 0;
    } else {
      playSound('miss.mp3');
    }
  }

  Future<void> playSound(String asset) async {
    try {
      await player.play(AssetSource('assets/sounds/$asset'));
    } catch (_) {}
  }
}
