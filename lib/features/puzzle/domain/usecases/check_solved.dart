import '../repositories/puzzle_repository.dart';

class CheckSolved {
  final PuzzleRepository repo;
  CheckSolved(this.repo);
  Future<bool> call() => repo.isSolved();
}
