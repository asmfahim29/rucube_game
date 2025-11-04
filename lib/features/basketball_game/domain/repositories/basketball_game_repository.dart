import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/features/basketball_game/domain/entities/basketball_game.dart';

/// Repository interface for basketball_game functionality
abstract class BasketballGameRepository {
  /// Get list of basketball_game
  Future<Either<Failure, List<BasketballGame>>> getBasketballGame();
}
