import 'dart:ui';
import 'package:flame/events.dart';
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

    ball.hoop = hoop;

    // ✅ Listen to Bloc changes
    bloc.stream.listen((state) {
      // 1️⃣ When bloc gives a new ball velocity — shoot!
      if (state.ballVel != Offset.zero && !ball.isMoving) {
        ball.shoot(state.ballVel);

        // 🧹 Reset velocity in Bloc to prevent repeat
        bloc.add(ClearVelocity());
      }
      // Update hoop speed when it changes
      if (state.hoopSpeed != lastHoopSpeed) {
        lastHoopSpeed = state.hoopSpeed;
        hoop.setSpeed(state.hoopSpeed);
      }

      // 2️⃣ When game is reset
      if (state.isGameOver) return;
      if (state.score == 0 && state.lives == 5 && !ball.isMoving) {
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
        hasScored = true;
        bloc.add(Scored());
        playScoreSound();

        // Trigger the ball scoring animation (instead of instantly resetting)
        final hoopCenter = Vector2(
          hoop.position.x + hoop.size.x / 2,
          hoop.position.y + hoop.size.y / 2,
        );
        ball.animateScore(hoopCenter);

        // Optionally trigger the hoop’s visual animation too
        // hoop.triggerScoreAnimation();

        // Mark scoring complete after ball animation done
        Future.delayed(const Duration(milliseconds: 400), () {
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
    final distance = (p - ball.position).length;
    final ballRadius = ball.size.x / 2;

    // ✅ Allow touch only if near ball and not moving or scoring
    if (distance <= ballRadius * 1.2 && !ball.isMoving && !ball.isScoring) {
      bloc.add(ShotBegin(Offset(p.x, p.y)));
    }
  }

  void onPanUpdate(DragUpdateInfo info) {
    if (ball.isMoving) return; // ✅ Ignore updates while ball is in air

    final p = info.eventPosition.global;
    bloc.add(ShotDrag(Offset(p.x, p.y)));
  }

  void onPanEnd(DragEndInfo info) {
    // ✅ Block while moving or during score animation
    if (ball.isMoving || ball.isScoring) return;

    final p = info.velocity;
    bloc.add(ShotRelease(Offset(p.x, p.y)));
    onFlick(Offset(p.x, p.y));
  }
}