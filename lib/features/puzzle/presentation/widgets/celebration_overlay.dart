import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  final VoidCallback onNext;
  const CelebrationOverlay({super.key, required this.onNext});
  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  late final ConfettiController _c;
  @override
  void initState() { super.initState(); _c = ConfettiController(duration: const Duration(seconds: 2))..play(); }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(confettiController: _c, blastDirectionality: BlastDirectionality.explosive, numberOfParticles: 40),
      ),
      Center(
        child: AnimatedScale(
          scale: 1, duration: const Duration(milliseconds: 250),
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text("Level Complete!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Nice job 🎉"),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: widget.onNext, child: const Text("Next Level →")),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}
