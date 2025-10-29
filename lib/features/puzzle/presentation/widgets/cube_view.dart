import 'package:flutter/material.dart';
import 'package:rucube_game/features/puzzle/domain/entities/puzzle.dart';

class CubeView extends StatelessWidget {
  final List<RenderSticker> stickers;
  const CubeView({super.key, required this.stickers});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CubePainter(stickers),
      isComplex: true,
      willChange: true,
      child: const SizedBox.expand(),
    );
  }
}

class _CubePainter extends CustomPainter {
  final List<RenderSticker> stickers;
  _CubePainter(this.stickers);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width * 0.5, size.height * 0.55);
    for (final s in List.of(stickers)..sort((a, b) => a.depth.compareTo(b.depth))) {
      final path = s.path.shift(const Offset(-150, -120)); // center-ish
      final fill = Paint()..style = PaintingStyle.fill..color = s.color;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black.withOpacity(.15)
        ..strokeWidth = 1.2;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, stroke);
    }
    // soft shadow
    final sh = Paint()..color = Colors.black.withOpacity(.08);
    canvas.drawOval(Rect.fromCenter(center: const Offset(0, 140), width: 300, height: 50), sh);
  }

  @override
  bool shouldRepaint(_CubePainter oldDelegate) => oldDelegate.stickers != stickers;
}