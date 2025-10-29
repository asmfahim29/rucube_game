part of '../game_bloc.dart';

abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object?> get props => [];
}

class GameLoading extends GameState {}

class GameReady extends GameState {
  final LevelSpec level;
  final List<RenderSticker> render;
  final int moves;
  final Duration elapsed;
  const GameReady({required this.level, required this.render, required this.moves, required this.elapsed});

  GameReady copyWith({LevelSpec? level, List<RenderSticker>? render, int? moves, Duration? elapsed}) {
    return GameReady(
      level: level ?? this.level,
      render: render ?? this.render,
      moves: moves ?? this.moves,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  @override
  List<Object?> get props => [level, render, moves, elapsed];
}

class GameSolved extends GameState {
  final LevelSpec level;
  final int moves;
  final Duration time;
  const GameSolved({required this.level, required this.moves, required this.time});
  @override
  List<Object?> get props => [level, moves, time];
}

