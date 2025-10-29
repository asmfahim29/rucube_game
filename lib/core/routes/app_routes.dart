import 'package:flutter/material.dart';
import 'package:rucube_game/features/puzzle/presentation/pages/level_select_page.dart';

enum AppRoutes { product }

extension AppRoutesExtention on AppRoutes {
  Widget buildWidget<T extends Object>({T? arguments}) {
    switch (this) {
      case AppRoutes.product:
        return const LevelSelectPage();
    }
  }
}

