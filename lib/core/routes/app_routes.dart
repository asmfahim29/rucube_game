import 'package:flutter/material.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/pages/kickfree_2D_page.dart';
import 'package:rucube_game/features/puzzle/presentation/pages/level_select_page.dart';

enum AppRoutes { product, levelSelect, gameplay  }

extension AppRoutesExtention on AppRoutes {
  Widget buildWidget<T extends Object>({T? arguments}) {
    switch (this) {
      case AppRoutes.product:
        return const LevelSelectPage();
      case AppRoutes.levelSelect:
        return const LevelSelectPage();
      case AppRoutes.gameplay:
        final payload = arguments as KickFree2dPageArgs?;
        return GameplayPage(args: payload);
    }
  }
}

