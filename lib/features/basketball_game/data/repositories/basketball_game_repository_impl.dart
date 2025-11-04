import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/core/network/network_info.dart';
import '/features/basketball_game/data/datasources/basketball_game_local_datasource.dart';
import '/features/basketball_game/data/datasources/basketball_game_remote_datasource.dart';
import '/features/basketball_game/domain/entities/basketball_game.dart';
import '/features/basketball_game/domain/repositories/basketball_game_repository.dart';

/// Implementation of BasketballGameRepository
class BasketballGameRepositoryImpl implements BasketballGameRepository {
  final BasketballGameRemoteDataSource _remoteDataSource;
  final BasketballGameLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  BasketballGameRepositoryImpl({
    required BasketballGameRemoteDataSource remoteDataSource,
    required BasketballGameLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<BasketballGame>>> getBasketballGame() async {
    if (await _networkInfo.internetAvailable()) {
      try {
        final remoteBasketballGame = await _remoteDataSource.getBasketballGame();
        await _localDataSource.cacheBasketballGame(remoteBasketballGame.first);
        return Right(remoteBasketballGame);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      try {
        final localBasketballGame = await _localDataSource.getBasketballGame();
        return Right(localBasketballGame);
      } catch (e) {
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

}
