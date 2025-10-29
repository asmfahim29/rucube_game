import 'package:equatable/equatable.dart';

import '/features/puzzle/domain/entities/puzzle.dart';

/// State for Puzzle
sealed class PuzzleState extends Equatable {
  const PuzzleState();
  
  @override
  List<Object?> get props => [];
}

class PuzzleInitial extends PuzzleState {
  const PuzzleInitial();
}

class PuzzleLoading extends PuzzleState {
  const PuzzleLoading();
}

// class PuzzleLoaded extends PuzzleState {
//   final List<Puzzle> puzzle;
//
//   const PuzzleLoaded(this.puzzle);
//
//   @override
//   List<Object?> get props => [puzzle];
// }

class PuzzleError extends PuzzleState {
  final String message;
  
  const PuzzleError(this.message);
  
  @override
  List<Object?> get props => [message];
}
