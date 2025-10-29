import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/global_appbar.dart';
import '../../../../core/presentation/widgets/global_text.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlobalAppBar(
        title: "Leaderboard",
      ),
      body: Center(
        child: GlobalText(str: "Leaderboard Page"),
      ),
    );
  }
}
