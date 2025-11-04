import 'package:equatable/equatable.dart';

/// BasketballGame entity - Represents basketball_game in the business domain
class BasketballGame extends Equatable {
  final int id;
  // Add your entity properties here

  const BasketballGame({
    required this.id,

  });

  @override
  List<Object?> get props => [id];
}
