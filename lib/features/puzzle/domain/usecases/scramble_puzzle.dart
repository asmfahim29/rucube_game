import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class ScramblePuzzle {
  final PuzzleRepository repo;
  ScramblePuzzle(this.repo);
  Future<List<RenderSticker>> call(int moves) => repo.scramble(moves);
}
