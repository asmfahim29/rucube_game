import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/features/leaderboard/data/models/leaderboard_model.dart';

/// Interface for leaderboard remote data source
abstract class LeaderboardRemoteDataSource {
  /// Get leaderboard from the remote API
  Future<List<LeaderboardModel>> getLeaderboard();

}

/// Implementation of leaderboard remote data source
class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  final ApiClient _apiClient;

  LeaderboardRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<LeaderboardModel>> getLeaderboard() async {
    try {
      final response = await _apiClient.request(
        endpoint: '/leaderboards', // Update with your API endpoint
        method: HttpMethod.get,
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => LeaderboardModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load leaderboard: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load leaderboard: $e');
    }
  }

}
