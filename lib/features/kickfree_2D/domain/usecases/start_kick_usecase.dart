import 'package:rucube_game/features/kickfree_2D/domain/repositories/kickfree_2D_repository.dart';

class StartKick {
  final Kickfree2dRepository repository;
  StartKick(this.repository);

  Future<void> call() async {
    // Logic before a new kick starts (e.g., reset states, countdown)
  }
}