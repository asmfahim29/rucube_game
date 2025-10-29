import 'package:equatable/equatable.dart';

/// Leaderboard entity - Represents leaderboard in the business domain
class Leaderboard extends Equatable {
  final int id;
  // Add your entity properties here

  const Leaderboard({
    required this.id,

  });

  @override
  List<Object?> get props => [id];
}
