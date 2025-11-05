import 'dart:ui';
import 'package:equatable/equatable.dart';

class BasketballGameState extends Equatable {
  // gameplay
  final int score;
  final int lives;            // chances left (5 → 4 → 3 → 2 → 1 → 0 = game over)
  final int level;
  final int misses;             // 1,2,3...
  final double hoopX;         // center x of the hoop
  final double hoopSpeed;     // px/s; increases by level
  final Offset ballPos;
  final Offset ballVel;
  final bool isGameOver;

  // aiming
  final bool aiming;
  final Offset aimStart;
  final Offset aimCurrent;

  // UI transients
  final bool scoreFlash;      // briefly true after each score
  final bool levelSplash;     // show "LEVEL N"
  final int? splashLevel;     // which level to show in splash

  const BasketballGameState({
    required this.score,
    required this.lives,
    required this.level,
    required this.misses,
    required this.hoopX,
    required this.hoopSpeed,
    required this.ballPos,
    required this.ballVel,
    required this.aiming,
    required this.aimStart,
    required this.aimCurrent,
    required this.scoreFlash,
    required this.levelSplash,
    required this.splashLevel,
    required this.isGameOver,
  });

  factory BasketballGameState.initial(double centerX) => BasketballGameState(
    score: 0,
    lives: 5,
    level: 1,
    misses: 0,
    hoopX: centerX,
    hoopSpeed: 0, // level 1: stuck in center
    ballPos: Offset(centerX, 1500),
    ballVel: Offset.zero,
    aiming: false,
    aimStart: Offset.zero,
    aimCurrent: Offset.zero,
    scoreFlash: false,
    levelSplash: false,  // FIX: Changed to false - don't show on initial load
    splashLevel: 1,
    isGameOver: false,
  );

  BasketballGameState copyWith({
    int? score,
    int? lives,
    int? level,
    int? misses,
    double? hoopX,
    double? hoopSpeed,
    Offset? ballPos,
    Offset? ballVel,
    bool? aiming,
    Offset? aimStart,
    Offset? aimCurrent,
    bool? scoreFlash,
    bool? levelSplash,
    int? splashLevel,
    bool? isGameOver,
  }) => BasketballGameState(
    score: score ?? this.score,
    lives: lives ?? this.lives,
    level: level ?? this.level,
    misses: misses ?? this.misses,
    hoopX: hoopX ?? this.hoopX,
    hoopSpeed: hoopSpeed ?? this.hoopSpeed,
    ballPos: ballPos ?? this.ballPos,
    ballVel: ballVel ?? this.ballVel,
    aiming: aiming ?? this.aiming,
    aimStart: aimStart ?? this.aimStart,
    aimCurrent: aimCurrent ?? this.aimCurrent,
    scoreFlash: scoreFlash ?? this.scoreFlash,
    levelSplash: levelSplash ?? this.levelSplash,
    splashLevel: splashLevel ?? this.splashLevel,
    isGameOver: isGameOver ?? this.isGameOver,
  );

  @override
  List<Object?> get props => [
    score, lives, level, misses, hoopX, hoopSpeed,
    ballPos, ballVel, aiming, aimStart, aimCurrent,
    scoreFlash, levelSplash, splashLevel,
    isGameOver,
  ];
}

