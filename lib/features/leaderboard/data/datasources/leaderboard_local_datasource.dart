import '/features/leaderboard/data/models/leaderboard_model.dart';

/// Interface for leaderboard local data source
abstract class LeaderboardLocalDataSource {
  /// Get cached leaderboard
  Future<List<LeaderboardModel>> getLeaderboard();

  /// Cache a single leaderboard
  Future<void> cacheLeaderboard(LeaderboardModel leaderboard);
}

/// Implementation of leaderboard local data source
class LeaderboardLocalDataSourceImpl implements LeaderboardLocalDataSource {
  // TODO: Implement local caching using SharedPreferences, Hive, or other storage

  @override
  Future<void> cacheLeaderboard(LeaderboardModel leaderboard) {
    // TODO: implement cacheLeaderboard
    throw UnimplementedError();
  }

  @override
  Future<List<LeaderboardModel>> getLeaderboard() {
    // TODO: implement getLeaderboard
    throw UnimplementedError();
  }
}
