// import 'package:dio/dio.dart';
//
// import '/core/network/api_client.dart';
// import '/features/puzzle/data/models/cube_model.dart';
//
// /// Interface for puzzle remote data source
// abstract class PuzzleRemoteDataSource {
//   /// Get puzzle from the remote API
//   Future<List<PuzzleModel>> getPuzzle();
//
// }
//
// /// Implementation of puzzle remote data source
// class PuzzleRemoteDataSourceImpl implements PuzzleRemoteDataSource {
//   final ApiClient _apiClient;
//
//   PuzzleRemoteDataSourceImpl({required ApiClient apiClient})
//       : _apiClient = apiClient;
//
//   @override
//   Future<List<PuzzleModel>> getPuzzle() async {
//     try {
//       final response = await _apiClient.request(
//         endpoint: '/puzzles', // Update with your API endpoint
//         method: HttpMethod.get,
//       );
//
//       final List<dynamic> data = response as List<dynamic>;
//       return data.map((json) => PuzzleModel.fromJson(json)).toList();
//     } on DioException catch (e) {
//       throw Exception('Failed to load puzzle: ${e.message}');
//     } catch (e) {
//       throw Exception('Failed to load puzzle: $e');
//     }
//   }
//
// }
