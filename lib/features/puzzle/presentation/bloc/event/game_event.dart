part of '../game_bloc.dart';

abstract class GameEvent {}

class StartLevel extends GameEvent {
  final int size;
  StartLevel(this.size);
}

class ShuffleCube extends GameEvent {
  final int moves;
  ShuffleCube({this.moves = 30});
}

class TransformUpdate extends GameEvent {
  final double dx;
  final double dy;
  final double scale;
  final int pointerCount;
  TransformUpdate({required this.dx, required this.dy, required this.scale, required this.pointerCount});
}

class TransformStart extends GameEvent {
  final Offset focalPoint;
  TransformStart(this.focalPoint);
}

class TransformEnd extends GameEvent {}

class FaceSwipeRequested extends GameEvent {
  final String direction; // 'up','down','left','right'
  FaceSwipeRequested(this.direction);
}

