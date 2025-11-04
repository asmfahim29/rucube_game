import '/features/basketball_game/data/models/basketball_game_model.dart';

/// Interface for basketball_game local data source
abstract class BasketballGameLocalDataSource {
  /// Get cached basketball_game
  Future<List<BasketballGameModel>> getBasketballGame();

  /// Cache a single basketball_game
  Future<void> cacheBasketballGame(BasketballGameModel basketball_game);
}

/// Implementation of basketball_game local data source
class BasketballGameLocalDataSourceImpl implements BasketballGameLocalDataSource {
  // TODO: Implement local caching using SharedPreferences, Hive, or other storage


  @override
  Future<List<BasketballGameModel>> getBasketballGame() {
    // TODO: implement getBasketballGame
    throw UnimplementedError();
  }


  @override
  Future<void> cacheBasketballGame(BasketballGameModel basketball_game) {
    // TODO: implement cacheBasketballGame
    throw UnimplementedError();
  }
}
