import 'package:dio/dio.dart';

import '/core/network/api_client.dart';
import '/features/kickfree_2D/data/models/kickfree_2D_model.dart';

/// Interface for kickfree_2D remote data source
abstract class Kickfree2dRemoteDataSource {
  /// Get kickfree_2D from the remote API
  Future<List<Kickfree2dModel>> getKickfree2d();

}

/// Implementation of kickfree_2D remote data source
class Kickfree2dRemoteDataSourceImpl implements Kickfree2dRemoteDataSource {
  final ApiClient _apiClient;

  Kickfree2dRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<Kickfree2dModel>> getKickfree2d() async {
    try {
      final response = await _apiClient.request(
        endpoint: '/kickfree_2Ds', // Update with your API endpoint
        method: HttpMethod.get,
      );

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => Kickfree2dModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load kickfree_2D: ${e.message}');
    } catch (e) {
      throw Exception('Failed to load kickfree_2D: $e');
    }
  }

}
