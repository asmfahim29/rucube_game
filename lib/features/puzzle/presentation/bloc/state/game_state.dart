part of '../game_bloc.dart';

class GameState {
  final CubeModel cube;
  final bool busy;
  final double rotX;
  final double rotY;
  final double scale;
  final int size;

  GameState({
    required this.cube,
    required this.busy,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.size,
  });

  GameState copyWith({
    CubeModel? cube,
    bool? busy,
    double? rotX,
    double? rotY,
    double? scale,
    int? size,
  }) {
    return GameState(
      cube: cube ?? this.cube,
      busy: busy ?? this.busy,
      rotX: rotX ?? this.rotX,
      rotY: rotY ?? this.rotY,
      scale: scale ?? this.scale,
      size: size ?? this.size,
    );
  }

  factory GameState.initial(int size) {
    return GameState(
      cube: CubeModel.create(size),
      busy: true,
      rotX: -0.4,
      rotY: 0.2,
      scale: 1.0,
      size: size,
    );
  }
}
