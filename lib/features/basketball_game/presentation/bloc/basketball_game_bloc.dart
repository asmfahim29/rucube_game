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
const _kSpeedPerLevel = 120.0; // L2: 120, L3: 240...

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
  }

  void _onStart(GameStarted e, Emitter<BasketballGameState> emit) {
    emit(BasketballGameState.initial(screenWidth / 2));
  }

  void _onBegin(ShotBegin e, Emitter<BasketballGameState> emit) {
    emit(state.copyWith(aiming: true, aimStart: e.p, aimCurrent: e.p));
  }

  void _onDrag(ShotDrag e, Emitter<BasketballGameState> emit) {
    emit(state.copyWith(aimCurrent: e.p));
  }

  void _onRelease(ShotRelease e, Emitter<BasketballGameState> emit) {
    final drag = state.aimStart - e.p;              // opposite of swipe
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

    // hoop movement (constant per level)
    var hx = state.hoopX;
    if (state.hoopSpeed > 0) {
      // ping-pong between margins
      final speed = state.hoopSpeed;
      hx += _dirFromSpeedTick(speed) * speed * dt;
      final margin = 40 + _kHoopWindow * 0.5;
      final minX = margin;
      final maxX = screenWidth - margin;
      if (hx < minX || hx > maxX) {
        // reflect back inside
        hx = hx.clamp(minX, maxX);
        // invert direction by flipping sign of speed using a tiny hack:
        // we store direction in sign of hoopSpeed; flip it
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
      // spawn a quick drop anim at rim (optional)
      add(SpawnScoreAnim(hx, _kHoopY));
    }

    // miss
    if (p.dy > _kFloorY) {
      add(Missed());
      // reset the ball for next shot
      emit(state.copyWith(ballPos: Offset(screenWidth/2, 1500), ballVel: Offset.zero, hoopX: hx));
      return;
    }

    emit(state.copyWith(ballPos: p, ballVel: v, hoopX: hx));
  }

  void _onScored(Scored e, Emitter<BasketballGameState> emit) {
    final newScore = state.score + 1;

    // decide if level up (every 10 points)
    final newLevel = (newScore ~/ 10) + 1; // 1..∞
    var levelUp = false;
    var nextSpeed = state.hoopSpeed;

    if (newLevel != state.level) {
      levelUp = true;
      // speed magnitude grows with level, direction sign preserved
      final dir = state.hoopSpeed == 0 ? 1.0 : (state.hoopSpeed > 0 ? 1.0 : -1.0);
      final mag = (newLevel - 1) * _kSpeedPerLevel;
      nextSpeed = dir * mag;
    }

    emit(state.copyWith(
      score: newScore,
      level: newLevel,
      hoopSpeed: nextSpeed,
      scoreFlash: true,
    ));

    // hide the score flash shortly after
    Future.microtask(() => add(HideScoreFlash()));

    if (levelUp) {
      add(ShowLevelSplash(newLevel));
      Future.delayed(const Duration(milliseconds: 900), () => add(HideLevelSplash()));
    }
  }

  void _onMissed(Missed e, Emitter<BasketballGameState> emit) {
    final left = state.lives - 1;
    emit(state.copyWith(lives: left));
    // your existing dialog should open when lives == 0
    // (trigger that from the UI layer watching lives)
  }

  // a tiny helper: sign for current speed
  double _dirFromSpeedTick(double s) => s == 0 ? 0 : (s > 0 ? 1 : -1);
}
