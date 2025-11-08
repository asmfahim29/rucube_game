import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/features/kickfree_2D/domain/entities/kickfree_2D.dart';

/// Repository interface for kickfree_2D functionality
abstract class Kickfree2dRepository {
  Future<void> saveScore(int score);
  Future<int> loadBestScore();
}
