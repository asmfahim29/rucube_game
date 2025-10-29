import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class InitPuzzle {
  final PuzzleRepository repo;
  InitPuzzle(this.repo);
  Future<List<RenderSticker>> call(LevelSpec spec) async {
    await repo.init(spec);
    return repo.scramble(0);
  }
}

