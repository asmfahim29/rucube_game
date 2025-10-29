import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/features/leaderboard/domain/entities/leaderboard.dart';

/// Repository interface for leaderboard functionality
abstract class LeaderboardRepository {
  /// Get list of leaderboard
  Future<Either<Failure, List<Leaderboard>>> getLeaderboard();
}
