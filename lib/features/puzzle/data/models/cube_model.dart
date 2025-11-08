import 'dart:math';

class CubeModel {
  final int size;
  // faces[faceIndex][row][col] -> int color id
  final List<List<List<int>>> faces;

  CubeModel._(this.size, this.faces);

  factory CubeModel.create(int size) {
    // initialize each face with a unique color id (0..5)
    final faces = List.generate(6, (f) => List.generate(size, (_) => List.filled(size, f)));
    return CubeModel._(size, faces);
  }

  bool isSolved() {
    for (var f = 0; f < 6; f++) {
      final first = faces[f][0][0];
      for (var r = 0; r < size; r++) {
        for (var c = 0; c < size; c++) {
          if (faces[f][r][c] != first) return false;
        }
      }
    }
    return true;
  }

  // rotate a face (faceIndex 0..5), layer = 0 is outermost (for NxN cubes, layer > 0 is inner slices),
  // clockwise = true for clockwise rotation of that face view.
  void rotateFace(int faceIndex, int layer, bool clockwise) {
    // rotate the face's own nxn matrix if layer == 0 (outer face)
    if (layer == 0) {
      _rotateMatrix(faces[faceIndex], clockwise);
    } else {
      // inner slice rotation does not change the printed face colors but affects edges —
      // we still need to handle edge cycles below.
    }

    // handle cycling adjacent edge strips for this face + layer.
    _applySliceTurn(faceIndex, layer, clockwise);
  }

  // Shuffle by applying random legal face turns. Ensure at least `moves` moves.
  void shuffle({int moves = 30, Random? rnd}) {
    rnd ??= Random();
    for (var i = 0; i < moves; i++) {
      final face = rnd.nextInt(6);
      final layer = 0; // start with outer layer; extending to inner slices is possible
      final clockwise = rnd.nextBool();
      rotateFace(face, layer, clockwise);
    }
    // Optional: ensure that scramble complexity is high enough (e.g., not solvable in 2 moves)
  }

  // Helper: rotate square matrix in place
  void _rotateMatrix(List<List<int>> mat, bool clockwise) {
    final n = mat.length;
    if (n <= 1) return;
    // transpose
    for (var i = 0; i < n; i++) {
      for (var j = i + 1; j < n; j++) {
        final tmp = mat[i][j];
        mat[i][j] = mat[j][i];
        mat[j][i] = tmp;
      }
    }
    if (clockwise) {
      // reverse rows
      for (var r = 0; r < n; r++) {
        mat[r].reverse();
      }
    } else {
      // reverse cols
      for (var c = 0; c < n ~/ 2; c++) {
        for (var r = 0; r < n; r++) {
          final tmp = mat[r][c];
          mat[r][c] = mat[r][n - 1 - c];
          mat[r][n - 1 - c] = tmp;
        }
      }
    }
  }

  // IMPORTANT: implement adjacency rules for cube faces here.
  // For brevity this function contains a simple scaffold. For a real NxN Rubik's cube
  // you must map faceIndex + layer -> four strips from adjacent faces and cycle them
  // clockwise/anticlockwise, preserving order and orientation.
  void _applySliceTurn(int faceIndex, int layer, bool clockwise) {
    // TODO: Replace with correct edge-cycle logic for NxN cube.
    // Example for 3x3 only outer layer for front face:
    if (size == 3 && layer == 0) {
      switch (faceIndex) {
        case 2: // left (example: adjust indices to match your face layout)
        // cycle appropriate edge strips between faces
          break;
        default:
          break;
      }
    }
    // For now, this is a no-op to let UI and wiring be implemented.
  }
}

// Small extension to reverse list in place
extension _ListReverse<E> on List<E> {
  void reverse() {
    for (var i = 0, j = length - 1; i < j; i++, j--) {
      final t = this[i];
      this[i] = this[j];
      this[j] = t;
    }
  }
}