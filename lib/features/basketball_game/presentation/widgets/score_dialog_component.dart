import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class ScoreDialog extends StatefulWidget {
  final int score;
  const ScoreDialog({super.key, required this.score});

  @override
  State<ScoreDialog> createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<ScoreDialog> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AlertDialog(
          title: const Text('🏀 Game Over'),
          content: Text(
            'Your Score: ${widget.score}\n${_message(widget.score)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Play Again'),
            ),
          ],
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          numberOfParticles: 20,
          colors: const [Colors.orange, Colors.blue, Colors.pink, Colors.purple],
        ),
      ],
    );
  }

  String _message(int score) {
    if (score == 0) return "😅 Better luck next time!";
    if (score < 5) return "👏 Not bad, keep practicing!";
    if (score < 10) return "🔥 You're getting good!";
    return "🏆 Legend! You’ve mastered it!";
  }
}

