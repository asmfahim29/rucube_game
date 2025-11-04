import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/features/basketball_game/data/models/basketball_game_model.dart';

/// Interface for basketball_game remote data source
abstract class BasketballGameRemoteDataSource {
  /// Get basketball_game from the remote API
  Future<List<BasketballGameModel>> getBasketballGame();

}

/// Implementation of basketball_game remote data source
class BasketballGameRemoteDataSourceImpl implements BasketballGameRemoteDataSource {
  final ApiClient _apiClient;

  BasketballGameRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<BasketballGameModel>> getBasketballGame() async {
    try {
      final response = await _apiClient.request(
        endpoint: '/basketball_games', // Update with your API endpoint
        method: HttpMethod.get,
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => BasketballGameModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load basketball_game: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load basketball_game: $e');
    }
  }

}
