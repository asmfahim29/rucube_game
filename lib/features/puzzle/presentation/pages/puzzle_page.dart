import 'package:flutter/material.dart';
import 'package:rucube_game/core/utils/enum.dart';
import 'package:rucube_game/features/puzzle/domain/entities/puzzle.dart';
import 'package:rucube_game/features/puzzle/presentation/bloc/game_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rucube_game/features/puzzle/presentation/widgets/celebration_overlay.dart';
import 'package:rucube_game/features/puzzle/presentation/widgets/cube_view.dart';

class GamePage extends StatelessWidget {
  final LevelSpec level;
  const GamePage({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Use the public CubeWebViewState type here
    final cubeKey = GlobalKey<CubeWebViewState>();

    return BlocBuilder<RucubeGameBloc, GameState>(
      builder: (context, state) {
        Widget body;
        if (state is GameLoading) {
          body = const Center(child: CircularProgressIndicator());
        } else if (state is GameSolved) {
          body = Stack(children: [
            const _Backdrop(),
            CelebrationOverlay(onNext: () => context.read<RucubeGameBloc>().add(const NextLevelRequested())),
          ]);
        } else if (state is GameReady) {
          body = Column(
            children: [
              const SizedBox(height: 12),
              _Hud(level: state.level, moves: state.moves, elapsed: state.elapsed),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: CubeWebView(
                  key: cubeKey,
                  onJsMessage: (msg) {
                    if (msg['type'] == 'moveComplete') {
                      // handle messages from the webview (optional)
                    }
                  },
                ),
              )),
              _MovePad(
                onDo: (m) {
                  context.read<RucubeGameBloc>().add(MoveCommitted(m));
                },
                onScramble: () {
                  context.read<RucubeGameBloc>().add(const ScrambleRequested(moves: 12));
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    try {
                      cubeKey.currentState?.scramble(12);
                    } catch (e) {}
                  });
                },
              ),
              const SizedBox(height: 12),
            ],
          );
        } else {
          body = const SizedBox.shrink();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F12),
          appBar: AppBar(
            title: const Text("Cubely"),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          body: body,
        );
      },
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF111318), Color(0xFF0F0F12)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}

class _Hud extends StatelessWidget {
  final LevelSpec level;
  final int moves;
  final Duration elapsed;
  const _Hud({required this.level, required this.moves, required this.elapsed});
  @override
  Widget build(BuildContext context) {
    String fmt(Duration d){
      final m = d.inMinutes.remainder(60).toString().padLeft(2,'0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2,'0');
      return "$m:$s";
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: [
          Chip(label: Text("Level: ${level.size}×${level.size}")),
          const Spacer(),
          Chip(label: Text("Moves: $moves")),
          const SizedBox(width: 8),
          Chip(label: Text(fmt(elapsed))),
        ],
      ),
    );
  }
}

class _MovePad extends StatelessWidget {
  final void Function(Move) onDo;
  final VoidCallback onScramble;
  const _MovePad({required this.onDo, required this.onScramble});

  Widget _btn(String t, Move m) => ElevatedButton(onPressed: () => onDo(m), child: Text(t));

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8, runSpacing: 8,
      children: [
        _btn('U', const Move(Face.U, Dir.cw)),
        _btn("U'", const Move(Face.U, Dir.ccw)),
        _btn('D', const Move(Face.D, Dir.cw)),
        _btn("D'", const Move(Face.D, Dir.ccw)),
        _btn('L', const Move(Face.L, Dir.cw)),
        _btn("L'", const Move(Face.L, Dir.ccw)),
        _btn('R', const Move(Face.R, Dir.cw)),
        _btn("R'", const Move(Face.R, Dir.ccw)),
        _btn('F', const Move(Face.F, Dir.cw)),
        _btn("F'", const Move(Face.F, Dir.ccw)),
        _btn('B', const Move(Face.B, Dir.cw)),
        _btn("B'", const Move(Face.B, Dir.ccw)),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: onScramble, child: const Text("Scramble")),
      ],
    );
  }
}