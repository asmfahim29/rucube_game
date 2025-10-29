import 'package:rucube_game/core/utils/enum.dart';

import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class NextLevel {
  final PuzzleRepository repo;
  NextLevel(this.repo);
  Future<LevelSpec> call(LevelSpec? current) async {
    if (current == null) {
      return const LevelSpec(shape: PuzzleShape.cube, size: 2, id: 'cube-2');
    }
    if (current.size < 10) {
      return LevelSpec(shape: PuzzleShape.cube, size: current.size + 1, id: 'cube-${current.size + 1}');
    }
    // loop back for now
    return const LevelSpec(shape: PuzzleShape.cube, size: 2, id: 'cube-2');
  }
}
