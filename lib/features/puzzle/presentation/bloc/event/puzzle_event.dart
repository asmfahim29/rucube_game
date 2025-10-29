import 'package:equatable/equatable.dart';

/// Events for Puzzle
sealed class PuzzleEvent extends Equatable {
  const PuzzleEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadPuzzle extends PuzzleEvent {
  const LoadPuzzle();
}

class RefreshPuzzle extends PuzzleEvent {
  const RefreshPuzzle();
}
