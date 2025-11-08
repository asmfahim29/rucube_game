import 'package:flutter/material.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/bloc/kickfree_2D_bloc.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/kickfree_game_logic.dart';

import '../../../../core/presentation/widgets/global_appbar.dart';
import '../../../../core/presentation/widgets/global_text.dart';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../../../core/di/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Kickfree2dPageArgs {
  final int levelId;
  const Kickfree2dPageArgs({required this.levelId});
}

class GameplayPage extends StatelessWidget {
  final Kickfree2dPageArgs? args;
  const GameplayPage({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final game = sl<KickfreeGame>();

    return BlocProvider(
      create: (_) => sl<Kickfree2dBloc>(),
      child: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

