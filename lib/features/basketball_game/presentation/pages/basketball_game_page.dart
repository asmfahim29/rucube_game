import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flame/game.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/event/basketball_game_event.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/state/basketball_game_state.dart';
import 'package:rucube_game/features/basketball_game/presentation/widgets/score_dialog_component.dart';

import '../widgets/basketball_game_logic_widget.dart';

class BasketballGameScreen extends StatelessWidget {
  const BasketballGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BasketballGameBloc>();
    final game = BasketballGame(bloc);

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: BlocListener<BasketballGameBloc, BasketballGameState>(
          listenWhen: (previous, current) => previous.isGameOver != current.isGameOver,
          listener: (context, state) {
            if (state.isGameOver) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => ScoreDialog(score: state.score),
              ).whenComplete((){
                bloc.add(ResetGame());
              });
            }
          },
          child: GestureDetector(
            onPanUpdate: (details) {
              // optional: track drag distance for power bar
            },
            onPanEnd: (details) {
              game.onFlick(details.velocity.pixelsPerSecond);
            },
            child: Stack(
              children: [
                GameWidget(
                  game: game,
                  backgroundBuilder: (context) => Container(color: Colors.white),
                ),

                // CENTER SCORE
                Positioned.fill(
                  child: IgnorePointer(
                    child: Center(
                      child: BlocBuilder<BasketballGameBloc, BasketballGameState>(
                        buildWhen: (p, n) => p.score != n.score || p.scoreFlash != n.scoreFlash,
                        builder: (_, s) => AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: s.scoreFlash ? 1 : 0.9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              '${s.score}',
                              style: const TextStyle(
                                fontSize: 56,
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
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
                            width: 24,
                            height: 24,
                          )
                              : Container(
                            width: 24,
                            height: 24,
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