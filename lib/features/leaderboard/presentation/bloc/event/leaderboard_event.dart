import 'package:equatable/equatable.dart';

/// Events for Leaderboard
sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadLeaderboard extends LeaderboardEvent {
  const LoadLeaderboard();
}

class RefreshLeaderboard extends LeaderboardEvent {
  const RefreshLeaderboard();
}
