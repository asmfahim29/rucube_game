import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/state/basketball_game_state.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/score_dialog_component.dart';

import '../widgets/basketball_game_logic_widget.dart';

class BasketballGameScreen extends StatelessWidget {
  BasketballGameScreen({super.key});

  final _random = Random();

  final List<Color> _colorPalette = [
    Colors.lightBlueAccent.shade200,
    Colors.greenAccent.shade200,
    Colors.purple.shade200,
    Colors.teal.shade200,
    Colors.pink.shade200,
    Colors.deepPurple.shade200,
    Colors.cyan.shade200,
    Colors.lime.shade200,
    Colors.amber.shade200,
    Colors.indigo.shade200, // Chocolate
    Colors.white,
  ];

  Color _getBackgroundColor(int level) {
    // Randomly select a color from the palette
    return _colorPalette[_random.nextInt(_colorPalette.length)];
  }

  @override
  Widget build(BuildContext context) {
    Offset? startPosition;
    final bloc = context.read<BasketballGameBloc>();
    final game = BasketballGame(bloc);

    return Scaffold(
      // backgroundColor: Colors.blue.shade50,
      body: BlocListener<BasketballGameBloc, BasketballGameState>(
          listenWhen: (previous, current) =>
          previous.isGameOver != current.isGameOver,
          listener: (context, state) {
            if (state.isGameOver) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ScoreDialog(score: state.score),
              ).whenComplete(() {
                // Reset BLoC state
                bloc.add(ResetGame());

                // Reset game components
                game.resetGame();
              });
            }
          },
          child: GestureDetector(
            onPanStart: (details) {
              final bloc = context.read<BasketballGameBloc>();
              final pos = details.globalPosition;
              startPosition = details.localPosition;
              bloc.add(ShotBegin(Offset(pos.dx, pos.dy)));
            },
            onPanUpdate: (details) {
              final bloc = context.read<BasketballGameBloc>();
              final pos = details.globalPosition;
              bloc.add(ShotDrag(Offset(pos.dx, pos.dy)));
            },
            onPanEnd: (details) {
              if (startPosition == null) return;

              final ballPos = game.ball.position;
              final dx = startPosition!.dx - ballPos.x;
              final dy = startPosition!.dy - ballPos.y;
              final distance = sqrt(dx * dx + dy * dy);

              if (distance < 80) {
                // Only shoot if the gesture started near the ball
                game.onFlick(details.velocity.pixelsPerSecond);
              }
              startPosition = null;
            },
            child: Stack(
              children: [

                BlocBuilder<BasketballGameBloc, BasketballGameState>(
                  buildWhen: (p, n) => p.level != n.level,
                  builder: (_, state) => AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    child: GameWidget(
                      game: game,
                      backgroundBuilder: (context) => Container(
                        color: _getBackgroundColor(state.level),
                      ),
                    ),
                  ),
                ),

                // CENTER SCORE
                Positioned(
                  left: 16,
                  top: 32,
                  child: IgnorePointer(
                    child: Center(
                      child: BlocBuilder<BasketballGameBloc, BasketballGameState>(
                        buildWhen: (p, n) => p.score != n.score || p.scoreFlash != n.scoreFlash,
                        builder: (_, s) => AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1a1a1a),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.8),
                              width: 2,
                            ),
                          ),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontSize: 14,
                              color: s.scoreFlash ? Colors.red : const Color(0xFFff3333),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'SCORE:',
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${s.score}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // FIX 5: LIVES - Show basketball images or grey circles
                Positioned(
                  right: 16,
                  top: 32,
                  child: BlocBuilder<BasketballGameBloc, BasketballGameState>(
                    buildWhen: (p, n) => p.lives != n.lives,
                    builder: (_, s) => Row(
                      children: List.generate(5, (i) {
                        final filled = i < s.lives;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: filled
                              ? Image.asset(
                            'assets/images/basketball.png',
                            width: 20,
                            height: 20,
                          )
                              : Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.withOpacity(0.3),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // LEVEL SPLASH (center top)
                Positioned.fill(
                  child: BlocBuilder<BasketballGameBloc, BasketballGameState>(
                    buildWhen: (p, n) => p.levelSplash != n.levelSplash || p.splashLevel != n.splashLevel,
                    builder: (_, s) {
                      if (!s.levelSplash) return const SizedBox.shrink();
                      return IgnorePointer(
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.20),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'LEVEL ${s.splashLevel}',
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}