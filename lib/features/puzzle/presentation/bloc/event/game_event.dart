part of '../game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object?> get props => [];
}

class GameStarted extends GameEvent {
  final LevelSpec level;
  const GameStarted(this.level);
}

class MoveCommitted extends GameEvent {
  final Move move;
  const MoveCommitted(this.move);
}

class ScrambleRequested extends GameEvent {
  final int? moves;
  const ScrambleRequested({this.moves});
}

class CheckSolvedRequested extends GameEvent {
  const CheckSolvedRequested();
}

class NextLevelRequested extends GameEvent {
  const NextLevelRequested();
}

class _RenderArrived extends GameEvent {
  final List<RenderSticker> render;
  const _RenderArrived(this.render);
}

