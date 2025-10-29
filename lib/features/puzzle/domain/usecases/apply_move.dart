import '../entities/puzzle.dart';
import '../repositories/puzzle_repository.dart';

class ApplyMove {
  final PuzzleRepository repo;
  ApplyMove(this.repo);
  Future<List<RenderSticker>> call(Move move) => repo.applyMove(move);
}
