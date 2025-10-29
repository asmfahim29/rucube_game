import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/core/network/network_info.dart';
import '/features/leaderboard/data/datasources/leaderboard_local_datasource.dart';
import '/features/leaderboard/data/datasources/leaderboard_remote_datasource.dart';
import '/features/leaderboard/domain/entities/leaderboard.dart';
import '/features/leaderboard/domain/repositories/leaderboard_repository.dart';

/// Implementation of LeaderboardRepository
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource _remoteDataSource;
  final LeaderboardLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  LeaderboardRepositoryImpl({
    required LeaderboardRemoteDataSource remoteDataSource,
    required LeaderboardLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<Leaderboard>>> getLeaderboard() async {
    if (await _networkInfo.internetAvailable()) {
      try {
        final remoteLeaderboard = await _remoteDataSource.getLeaderboard();
        await _localDataSource.cacheLeaderboard(remoteLeaderboard.first);
        return Right(remoteLeaderboard);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localLeaderboard = await _localDataSource.getLeaderboard();
        return Right(localLeaderboard);
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

}
