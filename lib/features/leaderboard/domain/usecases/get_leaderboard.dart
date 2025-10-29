import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/core/usecases/usecase.dart';
import '/features/leaderboard/domain/entities/leaderboard.dart';
import '/features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Use case for getting leaderboard
class GetLeaderboard implements UseCase<List<Leaderboard>, NoParams> {
  final LeaderboardRepository _repository;

  GetLeaderboard(this._repository);

  @override
  Future<Either<Failure, List<Leaderboard>>> call(NoParams params) async {
    return await _repository.getLeaderboard();
  }
}
