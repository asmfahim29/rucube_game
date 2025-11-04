import '/features/basketball_game/domain/entities/basketball_game.dart';

/// Model class for BasketballGame that extends the domain entity
class BasketballGameModel extends BasketballGame {
  const BasketballGameModel({
    required super.id,
  });

  /// Create a BasketballGameModel from JSON
  factory BasketballGameModel.fromJson(Map<String, dynamic> json) {
    return BasketballGameModel(
      id: json['id'] as int,
    
    );
  }

  /// Convert BasketballGameModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
     
    };
  }
}
