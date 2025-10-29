import 'package:dartz/dartz.dart';
import 'package:rucube_game/core/utils/enum.dart';

import '/core/error/failures.dart';
import '/features/puzzle/domain/entities/puzzle.dart';

/// Repository interface for puzzle functionality
abstract class PuzzleRepository {
  Future<void> init(LevelSpec spec);
  Future<List<RenderSticker>> applyMove(Move move);
  Future<List<RenderSticker>> scramble(int moves);
  Future<bool> isSolved();
  Stream<List<RenderSticker>> render$();
  LevelSpec get currentLevel;
}
