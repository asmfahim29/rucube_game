import 'dart:ui';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:rucube_game/core/constants/basket_ball_constants.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
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
  bool lastGameOverState = false;
  int lastLevel = 1;
  double lastHoopSpeed = 0.0;

  BasketballGame(this.bloc);

  @override
  Future<void> onLoad() async {
    hoop = HoopComponent();
    ball = BallComponent();

    add(hoop);
    add(ball);

    // Listen to BLoC state changes
    bloc.stream.listen((state) {
      // Update hoop speed when it changes
      if (state.hoopSpeed != lastHoopSpeed) {
        lastHoopSpeed = state.hoopSpeed;
        hoop.setSpeed(state.hoopSpeed);
      }

      // Reset game when transitioning from game over to new game
      if (lastGameOverState && !state.isGameOver) {
        resetGame();
      }

      lastGameOverState = state.isGameOver;
      lastLevel = state.level;
    });
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
        Future.delayed(const Duration(milliseconds: 150), () {
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
    ball.shoot(velocity);
  }

  void handleMissedShot() {
    playMissSound();
    bloc.add(Missed());
    ball.resetBall();
  }

  // NEW: Reset all game components
  void resetGame() {
    ball.resetBall();
    hoop.resetHoop();
    lastHoopSpeed = 0.0;
    lastLevel = 1;
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

  // Input: swipe/flick from ball area (like Messenger)
  void onPanStart(DragStartInfo info) {
    final p = info.eventPosition.global;
    // Only start if near the ball
    if ((p - ball.position).length <= kBallRadius * 1.4) {
      bloc.add(ShotBegin(Offset(p.x, p.y)));
    }
  }

  void onPanUpdate(DragUpdateInfo info) {
    final p = info.eventPosition.global;
    bloc.add(ShotDrag(Offset(p.x, p.y)));
  }

  void onPanEnd(DragEndInfo info) {
    final p = info.velocity;
    bloc.add(ShotRelease(Offset(p.x, p.y)));
  }
}