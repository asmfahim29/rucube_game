import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rucube_game/core/utils/enum.dart';
import 'package:rucube_game/features/puzzle/presentation/pages/puzzle_page.dart' show GamePage;
import '../../domain/entities/puzzle.dart';
import '../bloc/game_bloc.dart';

class LevelSelectPage extends StatelessWidget {
  const LevelSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = List.generate(9, (i) => LevelSpec(shape: PuzzleShape.cube, size: i+2, id: 'cube-${i+2}'));
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(title: const Text("Select Level"), backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.white),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: levels.length,
        itemBuilder: (_, i){
          final l = levels[i];
          return InkWell(
            onTap: (){
              context.read<RucubeGameBloc>().add(GameStarted(l));
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => GamePage(level: l)));
            },
            child: Card(
              color: const Color(0xFF181A20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text("${l.size}×${l.size}", style: const TextStyle(fontSize: 20, color: Colors.white))),
            ),
          );
        },
      ),
    );
  }
}
