import 'package:flutter/material.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/pages/kickfree_2D_page.dart';
import '../../../../core/routes/app_routes.dart';

class KickFreeLevelSelectPage extends StatelessWidget {
  const KickFreeLevelSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade800,
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppRoutes.gameplay
                    .buildWidget(arguments: const KickFree2dPageArgs(levelId: 1)),
              ),
            );
          },
          child: const Text('Start Free Kick'),
        ),
      ),
    );
  }
}
