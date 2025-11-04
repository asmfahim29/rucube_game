import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
import '/features/basketball_game/presentation/bloc/state/basketball_game_state.dart';

// tune these
const _kHoopY = 520.0;
const _kGravity = 2200.0;
const _kFriction = 0.998;
const _kHoopWindow = 240.0;
const _kFloorY = 1800.0;

// FIX 2: New speed progression - starts at 0, increases at score 5, saturates at score 9
const _kInitialSpeed = 0.0;        // Level 1: stationary
const _kSpeedIncrement = 80.0;     // Speed increase per level after score 5
const _kMaxSpeed = 320.0;          // Maximum speed (reached at score 9)

class BasketballGameBloc extends Bloc<BasketballGameEvent, BasketballGameState> {
  final double screenWidth;
  BasketballGameBloc(this.screenWidth)
      : super(BasketballGameState.initial(screenWidth / 2)) {
    on<GameStarted>(_onStart);
    on<Tick>(_onTick);
    on<ShotBegin>(_onBegin);
    on<ShotDrag>(_onDrag);
    on<ShotRelease>(_onRelease);
    on<Scored>(_onScored);
    on<Missed>(_onMissed);
    on<HideScoreFlash>((e, emit) => emit(state.copyWith(scoreFlash: false)));
    on<ShowLevelSplash>((e, emit) => emit(state.copyWith(levelSplash: true, splashLevel: e.level)));
    on<HideLevelSplash>((e, emit) => emit(state.copyWith(levelSplash: false)));
    on<ResetGame>(_onResetGame);
  }

  void _onStart(GameStarted e, Emitter<BasketballGameState> emit) {
    emit(BasketballGameState.initial(screenWidth / 2));
  }

  void _onResetGame(ResetGame e, Emitter<BasketballGameState> emit) {
    emit(BasketballGameState.initial(screenWidth / 2));
  }

  void _onBegin(ShotBegin e, Emitter<BasketballGameState> emit) {
    emit(state.copyWith(aiming: true, aimStart: e.p, aimCurrent: e.p));
  }

  void _onDrag(ShotDrag e, Emitter<BasketballGameState> emit) {
    emit(state.copyWith(aimCurrent: e.p));
  }

  void _onRelease(ShotRelease e, Emitter<BasketballGameState> emit) {
    final drag = state.aimStart - e.p;
    final v0 = Offset(drag.dx * 2.2, drag.dy * 2.2);
    emit(state.copyWith(aiming: false, ballVel: v0));
  }

  void _onTick(Tick e, Emitter<BasketballGameState> emit) {
    final dt = e.dt;

    // integrate ball
    var v = state.ballVel;
    var p = state.ballPos;
    v = Offset(v.dx * _kFriction, (v.dy + _kGravity * dt) * _kFriction);
    p = Offset(p.dx + v.dx * dt, p.dy + v.dy * dt);

    // hoop movement
    var hx = state.hoopX;
    if (state.hoopSpeed.abs() > 0.1) {
      final speed = state.hoopSpeed;
      hx += _dirFromSpeedTick(speed) * speed.abs() * dt;
      final margin = 40 + _kHoopWindow * 0.5;
      final minX = margin;
      final maxX = screenWidth - margin;
      if (hx < minX || hx > maxX) {
        hx = hx.clamp(minX, maxX);
        final newSpeed = -state.hoopSpeed;
        emit(state.copyWith(hoopX: hx, ballPos: p, ballVel: v, hoopSpeed: newSpeed));
        return;
      }
    }

    // score detection: crossing hoop line downward within window
    final crossedDown = state.ballPos.dy < _kHoopY && p.dy >= _kHoopY && v.dy > 0;
    final within = (p.dx - hx).abs() <= (_kHoopWindow * 0.5);
    if (crossedDown && within) {
      add(Scored());
      add(SpawnScoreAnim(hx, _kHoopY));
    }

    // miss - only if ball goes below floor
    if (p.dy > _kFloorY) {
      add(Missed());
      emit(state.copyWith(ballPos: Offset(screenWidth/2, 1500), ballVel: Offset.zero, hoopX: hx));
      return;
    }

    emit(state.copyWith(ballPos: p, ballVel: v, hoopX: hx));
  }

  void _onScored(Scored e, Emitter<BasketballGameState> emit) {
    final newScore = state.score + 1;

    // FIX 2: New speed progression logic
    double nextSpeed = _calculateHoopSpeed(newScore, state.hoopSpeed);

    // Determine level based on score for display purposes
    final newLevel = (newScore ~/ 5) + 1;
    final levelUp = newLevel != state.level;

    emit(state.copyWith(
      score: newScore,
      level: newLevel,
      hoopSpeed: nextSpeed,
      scoreFlash: true,
    ));

    Future.microtask(() => add(HideScoreFlash()));

    if (levelUp) {
      add(ShowLevelSplash(newLevel));
      Future.delayed(const Duration(milliseconds: 900), () => add(HideLevelSplash()));
    }
  }

  // FIX 2: Calculate hoop speed based on score
  double _calculateHoopSpeed(int score, double currentSpeed) {
    if (score < 5) {
      // Scores 0-4: Hoop is stationary
      return 0.0;
    } else if (score >= 9) {
      // Score 9+: Speed saturates at maximum
      final dir = currentSpeed == 0 ? 1.0 : (currentSpeed > 0 ? 1.0 : -1.0);
      return dir * _kMaxSpeed;
    } else {
      // Scores 5-8: Speed increases gradually
      final dir = currentSpeed == 0 ? 1.0 : (currentSpeed > 0 ? 1.0 : -1.0);
      final speedLevel = score - 4; // 1, 2, 3, 4 for scores 5, 6, 7, 8
      final speed = _kSpeedIncrement * speedLevel;
      return dir * speed.clamp(0, _kMaxSpeed);
    }
  }

  void _onMissed(Missed e, Emitter<BasketballGameState> emit) {
    final left = state.lives - 1;

    if (left <= 0) {
      emit(state.copyWith(lives: 0, isGameOver: true));
    } else {
      emit(state.copyWith(lives: left));
    }
  }

  double _dirFromSpeedTick(double s) => s == 0 ? 0 : (s > 0 ? 1 : -1);
}