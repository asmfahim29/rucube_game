import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/kickfree_2D_widget.dart';

class KickFree2dPageArgs {
  final int levelId;
  const KickFree2dPageArgs({required this.levelId});
}

class GameplayPage extends StatelessWidget {
  final KickFree2dPageArgs? args;
  const GameplayPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final game = KickFree2dGameLogic();

    return Scaffold(
      body: GameWidget(game: game),
    );
  }
}

