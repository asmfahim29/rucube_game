import 'dart:ui';
import 'package:flame/game.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/play_ground_widget.dart';
import 'ball_component.dart';
import 'hoop_component.dart';
import 'package:audioplayers/audioplayers.dart';

class BasketballGame extends FlameGame {
  final BasketballGameBloc bloc;
  late BallComponent ball;
  late HoopComponent hoop;
  final AudioPlayer scorePlayer = AudioPlayer();
  final AudioPlayer missPlayer = AudioPlayer();
  bool hasScored = false;

  BasketballGame(this.bloc);

  @override
  Future<void> onLoad() async {
    ball = BallComponent();
    hoop = HoopComponent();
    final boundary = PlaygroundBoundary();
    final audience = Audience();

    addAll([boundary, audience, hoop, ball]); // Add to game components
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (ball.isMoving && !hasScored) {
      // FIX 4: Early miss detection - if ball goes too far left/right
      final screenWidth = size.x;
      final hoopCenterX = hoop.position.x + hoop.size.x / 2;
      const hoopWidth = 80.0; // hoop detection zone

      // If ball is moving down and has passed hoop height, check horizontal position
      if (ball.velocity.y > 0 && ball.position.y > hoop.position.y + 20) {
        final horizontalDistance = (ball.position.x - hoopCenterX).abs();

        // If ball is too far from hoop horizontally, it's definitely a miss
        if (horizontalDistance > hoopWidth) {
          ball.isMoving = false;
          handleMissedShot();
          ball.resetBall();
          return;
        }
      }

      // Also check if ball goes off screen horizontally
      if (ball.position.x < -50 || ball.position.x > screenWidth + 50) {
        ball.isMoving = false;
        handleMissedShot();
        ball.resetBall();
        return;
      }

      // Score detection
      if (hoop.checkScore(ball.position)) {
        ball.isMoving = false;
        hasScored = true;
        bloc.add(Scored());
        playScoreSound();

        // FIX 3: Trigger score animation on hoop
        hoop.triggerScoreAnimation();

        // Reset ball after animation completes
        Future.delayed(const Duration(milliseconds: 800), () {
          ball.resetBall();
          hasScored = false;
        });
      }
    }

    // Bottom boundary check (only if ball hasn't scored)
    if (ball.isMoving && ball.position.y > size.y + 50) {
      ball.isMoving = false;
      handleMissedShot();
      ball.resetBall();
    }
  }

  void onFlick(Offset velocity) {
    if (!ball.isMoving && !hasScored) {
      ball.shoot(velocity);
    }
  }

  void handleMissedShot() async {
    // FIX 1: Immediate sound playback with separate player
    await playMissSound();
    bloc.add(Missed());
  }

  Future<void> playScoreSound() async {
    try {
      await scorePlayer.play(AssetSource('sounds/score.mp3'));
    } catch (e) {
      print('Error playing score sound: $e');
    }
  }

  Future<void> playMissSound() async {
    try {
      await missPlayer.play(AssetSource('sounds/bounce.mp3'));
    } catch (e) {
      print('Error playing miss sound: $e');
    }
  }
}