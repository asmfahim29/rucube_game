import '/features/kickfree_2D/domain/repositories/kickfree_2D_repository.dart';

/// Implementation of Kickfree2dRepository
class Kickfree2dRepositoryImpl implements Kickfree2dRepository {
  int _bestScore = 0;

  @override
  Future<void> saveScore(int score) async {
    if (score > _bestScore) _bestScore = score;
  }

  @override
  Future<int> loadBestScore() async => _bestScore;
}
