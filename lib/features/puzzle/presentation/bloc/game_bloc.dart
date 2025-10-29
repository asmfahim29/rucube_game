import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rucube_game/features/puzzle/domain/entities/puzzle.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/apply_move.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/check_solved.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/get_puzzle.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/next_level.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/scramble_puzzle.dart';

part 'event/game_event.dart';
part 'state/game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final InitPuzzle initPuzzle;
  final ApplyMove applyMove;
  final ScramblePuzzle scramblePuzzle;
  final CheckSolved checkSolved;
  final NextLevel nextLevel;
  final Stream<List<RenderSticker>> renderStream;

  StreamSubscription<List<RenderSticker>>? _sub;
  DateTime? _start;

  GameBloc({
    required this.initPuzzle,
    required this.applyMove,
    required this.scramblePuzzle,
    required this.checkSolved,
    required this.nextLevel,
    required this.renderStream,
  }) : super(GameLoading()) {
    on<GameStarted>(_onStarted);
    on<MoveCommitted>(_onMove);
    on<ScrambleRequested>(_onScramble);
    on<CheckSolvedRequested>(_onCheck);
    on<NextLevelRequested>(_onNext);
    on<_RenderArrived>((e, emit) {
      if (state is GameReady) {
        emit((state as GameReady).copyWith(render: e.render));
      }
    });
  }

  Future<void> _onStarted(GameStarted e, Emitter<GameState> emit) async {
    emit(GameLoading());
    final render = await initPuzzle(e.level);
    _start = DateTime.now();
    _sub?.cancel();
    _sub = renderStream.listen((r) => add(_RenderArrived(r)));
    emit(GameReady(level: e.level, render: render, moves: 0, elapsed: Duration.zero));
  }

  Future<void> _onMove(MoveCommitted e, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final s = state as GameReady;
    final render = await applyMove(e.move);
    final dur = _elapsed();
    emit(s.copyWith(render: render, moves: s.moves + 1, elapsed: dur));
    add(const CheckSolvedRequested());
  }

  Future<void> _onScramble(ScrambleRequested e, Emitter<GameState> emit) async {
    if (state is! GameReady) return;
    final s = state as GameReady;
    final render = await scramblePuzzle(e.moves ?? 15);
    _start = DateTime.now();
    emit(s.copyWith(render: render, moves: 0, elapsed: Duration.zero));
  }

  Future<void> _onCheck(CheckSolvedRequested e, Emitter<GameState> emit) async {
    final solved = await checkSolved();
    if (solved && state is GameReady) {
      final s = state as GameReady;
      emit(GameSolved(level: s.level, moves: s.moves, time: s.elapsed));
    }
  }

  Future<void> _onNext(NextLevelRequested e, Emitter<GameState> emit) async {
    final lvl = await nextLevel((state is GameSolved) ? (state as GameSolved).level : null);
    add(GameStarted(lvl));
  }

  Duration _elapsed() => _start == null ? Duration.zero : DateTime.now().difference(_start!);

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
