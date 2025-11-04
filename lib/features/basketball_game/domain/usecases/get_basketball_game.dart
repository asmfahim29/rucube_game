import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/core/usecases/usecase.dart';
import '/features/basketball_game/domain/entities/basketball_game.dart';
import '/features/basketball_game/domain/repositories/basketball_game_repository.dart';

/// Use case for getting basketball_game
class GetBasketballGame implements UseCase<List<BasketballGame>, NoParams> {
  final BasketballGameRepository _repository;

  GetBasketballGame(this._repository);

  @override
  Future<Either<Failure, List<BasketballGame>>> call(NoParams params) async {
    return await _repository.getBasketballGame();
  }
}
