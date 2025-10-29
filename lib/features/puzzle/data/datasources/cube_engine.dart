import 'package:rucube_game/core/utils/enum.dart';
import 'package:rucube_game/features/puzzle/domain/entities/puzzle.dart';

import 'dart:math';
import 'package:flutter/material.dart';

/// Colors by face index 0..5 (U,D,L,R,F,B)
const _palette = <Color>[
  Color(0xFFFFFFFF), // U - white
  Color(0xFFFFD500), // D - yellow
  Color(0xFF009B48), // L - green
  Color(0xFFB71234), // R - red
  Color(0xFF0046AD), // F - blue
  Color(0xFFFF5800), // B - orange
];

class CubeEngine {
  final int n;
  late List<List<int>> faces; // 6 faces, each n*n stickers flattened
  CubeEngine(this.n) {
    assert(n >= 2);
    _reset();
  }

  void _reset() {
    faces = List.generate(6, (f) => List<int>.filled(n * n, f));
  }

  bool isSolved() {
    for (var f = 0; f < 6; f++) {
      final color = faces[f][0];
      for (final s in faces[f]) {
        if (s != color) return false;
      }
    }
    return true;
  }

  // Helpers
  int _idx(int r, int c) => r * n + c;

  void turn(Face face, Dir dir) {
    final k = (dir == Dir.cw) ? 1 : 3; // 90° CW vs CCW (3 CWs)
    for (int i = 0; i < k; i++) {
      _turnOnce(face);
    }
  }

  // Implements standard 3x3 notation mapping; extended to NxN outer layer only.
  void _turnOnce(Face f) {
    // rotate face stickers (outer face)
    _rotateFaceCW(_faceIndex(f));

    // cycle adjacent strips (only outer layer for MVP)
    final strip = _extractStrips(f);
    final rotated = [strip.last, ...strip.take(strip.length - 1)];
    _applyStrips(f, rotated);
  }

  int _faceIndex(Face f) => switch (f) {
    Face.U => 0, Face.D => 1, Face.L => 2, Face.R => 3, Face.F => 4, Face.B => 5
  };

  void _rotateFaceCW(int fi) {
    final a = faces[fi];
    final b = List<int>.from(a);
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final to = _idx(c, n - 1 - r);
        final from = _idx(r, c);
        b[to] = a[from];
      }
    }
    faces[fi] = b;
  }

  // Extract four neighbor strips for a given move (outermost row/col).
  // For 2x2, each strip has length n = 2.
  List<List<int>> _extractStrips(Face f) {
    final N = n;
    // shorthand
    List<int> row(int fi, int rr) => [for (int c = 0; c < N; c++) faces[fi][_idx(rr, c)]];
    List<int> col(int fi, int cc) => [for (int r = 0; r < N; r++) faces[fi][_idx(r, cc)]];

    // Mapping based on standard cube (F facing you, U on top, R right-handed)
    switch (f) {
      case Face.U:
        return [row(5, 0).reversed.toList(), row(3, 0), row(4, 0), row(2, 0).reversed.toList()];
      case Face.D:
        return [row(4, N - 1), row(3, N - 1).reversed.toList(), row(5, N - 1), row(2, N - 1).reversed.toList()];
      case Face.L:
        return [col(4, 0), col(0, 0), col(5, N - 1).reversed.toList(), col(1, 0)];
      case Face.R:
        return [col(5, 0).reversed.toList(), col(0, N - 1), col(4, N - 1), col(1, N - 1)];
      case Face.F:
        return [row(0, N - 1), col(3, 0), row(1, 0).reversed.toList(), col(2, N - 1).reversed.toList()];
      case Face.B:
        return [row(0, 0).reversed.toList(), col(2, 0), row(1, N - 1), col(3, N - 1).reversed.toList()];
    }
  }

  void _applyStrips(Face f, List<List<int>> strips) {
    final N = n;
    void setRow(int fi, int rr, List<int> s) {
      for (int c = 0; c < N; c++) faces[fi][_idx(rr, c)] = s[c];
    }
    void setCol(int fi, int cc, List<int> s) {
      for (int r = 0; r < N; r++) faces[fi][_idx(r, cc)] = s[r];
    }

    switch (f) {
      case Face.U:
        setRow(5, 0, strips[0].reversed.toList());
        setRow(3, 0, strips[1]);
        setRow(4, 0, strips[2]);
        setRow(2, 0, strips[3].reversed.toList());
        break;
      case Face.D:
        setRow(4, n - 1, strips[0]);
        setRow(3, n - 1, strips[1].reversed.toList());
        setRow(5, n - 1, strips[2]);
        setRow(2, n - 1, strips[3].reversed.toList());
        break;
      case Face.L:
        setCol(4, 0, strips[0]);
        setCol(0, 0, strips[1]);
        setCol(5, n - 1, strips[2].reversed.toList());
        setCol(1, 0, strips[3]);
        break;
      case Face.R:
        setCol(5, 0, strips[0].reversed.toList());
        setCol(0, n - 1, strips[1]);
        setCol(4, n - 1, strips[2]);
        setCol(1, n - 1, strips[3]);
        break;
      case Face.F:
        setRow(0, n - 1, strips[0]);
        setCol(3, 0, strips[1]);
        setRow(1, 0, strips[2].reversed.toList());
        setCol(2, n - 1, strips[3].reversed.toList());
        break;
      case Face.B:
        setRow(0, 0, strips[0].reversed.toList());
        setCol(2, 0, strips[1]);
        setRow(1, n - 1, strips[2]);
        setCol(3, n - 1, strips[3].reversed.toList());
        break;
    }
  }

  // Simple scramble
  void scramble(int moves) {
    final r = Random();
    const fs = Face.values;
    for (int i = 0; i < moves; i++) {
      turn(fs[r.nextInt(fs.length)], r.nextBool() ? Dir.cw : Dir.ccw);
    }
  }

  /// Very simple 2.5D isometric painter data (front/top/right faces only).
  List<RenderSticker> render(Size size) {
    final stickers = <RenderSticker>[];
    final s = min(size.width, size.height);
    final tile = s / (n * 1.6);
    final ox = -s * .25, oy = -s * .10;

    Path square(double x, double y) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, tile * .9, tile * .9),
          const Radius.circular(4),
        ));
    }

    // FRONT (face 4)
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final x = ox + c * tile;
        final y = oy + r * tile;
        stickers.add(RenderSticker(
          path: square(x, y),
          color: _palette[faces[4][_idx(r, c)]],
          depth: 1,
        ));
      }
    }
    // TOP (face 0) shifted up-left
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final x = ox + c * tile - r * (tile * .5);
        final y = oy - n * tile * .7 - r * (tile * .5);
        stickers.add(RenderSticker(
          path: square(x, y),
          color: _palette[faces[0][_idx(r, c)]].withValues(alpha: .95, blue: .95, green: .95, red: .95),
          depth: 0.5,
        ));
      }
    }
    // RIGHT (face 3) shifted right-down
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final x = ox + n * tile * 1.1 + c * (tile * .9) + r * (tile * .2);
        final y = oy + r * (tile * 1.0);
        stickers.add(RenderSticker(
          path: square(x, y),
          color: _palette[faces[3][_idx(r, c)]].withValues(alpha: .95, blue: .95, green: .95, red: .95),
          depth: 1.2,
        ));
      }
    }
    return stickers;
  }
}
