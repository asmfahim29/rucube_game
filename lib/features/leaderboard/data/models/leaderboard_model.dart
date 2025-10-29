import '/features/leaderboard/domain/entities/leaderboard.dart';

/// Model class for Leaderboard that extends the domain entity
class LeaderboardModel extends Leaderboard {
  const LeaderboardModel({
    required super.id,
  });

  /// Create a LeaderboardModel from JSON
  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['id'] as int,
    
    );
  }

  /// Convert LeaderboardModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
     
    };
  }
}
