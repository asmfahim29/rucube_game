import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:rucube_game/core/utils/enum.dart';

/// Puzzle entity - Represents puzzle in the business domain
class LevelSpec extends Equatable {
  final PuzzleShape shape;
  final int size; // 2..10 for cubes
  final String id;
  const LevelSpec({required this.shape, required this.size, required this.id});
  @override
  List<Object?> get props => [shape, size, id];
}

class Move extends Equatable {
  final Face face;
  final Dir dir;
  const Move(this.face, this.dir);
  @override
  List<Object?> get props => [face, dir];
}

/// Minimal painter data for a 2.5D cube (three visible faces).
class RenderSticker extends Equatable {
  final Path path;
  final Color color;
  final double depth;
  const RenderSticker({required this.path, required this.color, required this.depth});
  @override
  List<Object?> get props => [color, depth];
}