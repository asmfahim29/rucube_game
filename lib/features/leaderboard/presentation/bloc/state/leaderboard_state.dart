import 'package:equatable/equatable.dart';

import '/features/leaderboard/domain/entities/leaderboard.dart';

/// State for Leaderboard
sealed class LeaderboardState extends Equatable {
  const LeaderboardState();
  
  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  final List<Leaderboard> leaderboard;
  
  const LeaderboardLoaded(this.leaderboard);
  
  @override
  List<Object?> get props => [leaderboard];
}

class LeaderboardError extends LeaderboardState {
  final String message;
  
  const LeaderboardError(this.message);
  
  @override
  List<Object?> get props => [message];
}
