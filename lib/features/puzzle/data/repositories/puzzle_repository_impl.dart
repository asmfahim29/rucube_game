import 'dart:async';
import 'package:rucube_game/core/utils/enum.dart';
import '/features/puzzle/data/datasources/cube_engine.dart';
import '/features/puzzle/domain/entities/puzzle.dart';
import '/features/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:flutter/material.dart';

class PuzzleRepositoryImpl implements PuzzleRepository {
  late LevelSpec _level;
  CubeEngine? _cube;
  final _renderCtrl = StreamController<List<RenderSticker>>.broadcast();

  @override
  LevelSpec get currentLevel => _level;

  @override
  Future<void> init(LevelSpec spec) async {
    _level = spec;
    if (spec.shape == PuzzleShape.cube) {
      _cube = CubeEngine(spec.size);
      _emit(Size.zero);
    }
  }

  void _emit(Size size) {
    _renderCtrl.add(_cube?.render(const Size(600, 500)) ?? const []);
  }

  @override
  Future<List<RenderSticker>> applyMove(Move move) async {
    _cube?.turn(move.face, move.dir);
    final r = _cube?.render(const Size(600, 500)) ?? const [];
    _renderCtrl.add(r);
    return r;
  }

  @override
  Future<List<RenderSticker>> scramble(int moves) async {
    _cube?.scramble(moves);
    final r = _cube?.render(const Size(600, 500)) ?? const [];
    _renderCtrl.add(r);
    return r;
  }

  @override
  Future<bool> isSolved() async => _cube?.isSolved() ?? false;

  @override
  Stream<List<RenderSticker>> render$() => _renderCtrl.stream;
}
