import '/features/kickfree_2D/data/models/kickfree_2D_model.dart';

/// Interface for kickfree_2D local data source
abstract class Kickfree2dLocalDataSource {
  /// Get cached kickfree_2D
  Future<List<Kickfree2dModel>> getKickfree2d();

  /// Cache a single kickfree_2D
  Future<void> cacheKickfree2d(Kickfree2dModel kickfree_2D);
}

/// Implementation of kickfree_2D local data source
class Kickfree2dLocalDataSourceImpl implements Kickfree2dLocalDataSource {
  @override
  Future<void> cacheKickfree2d(Kickfree2dModel kickfree_2D) {
    // TODO: implement cacheKickfree2d
    throw UnimplementedError();
  }

  @override
  Future<List<Kickfree2dModel>> getKickfree2d() {
    // TODO: implement getKickfree2d
    throw UnimplementedError();
  }
  // TODO: Implement local caching using SharedPreferences, Hive, or other storage

}
