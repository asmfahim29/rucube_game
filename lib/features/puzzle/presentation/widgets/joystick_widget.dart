import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

typedef DirectionChanged = void Function(String? moveSymbol);

class VirtualJoystick extends StatefulWidget {
  final DirectionChanged onDirection;
  final bool useFB;   // if true, left/right map to F/B instead of L/R
  final bool prime;   // add "'" to moves
  const VirtualJoystick({super.key, required this.onDirection, this.useFB=false, this.prime=false});

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  Offset _knob = Offset.zero;
  Timer? _repeat;
  String? _currentMove;

  @override
  void dispose() {
    _repeat?.cancel();
    super.dispose();
  }

  void _startRepeat() {
    _repeat?.cancel();
    _repeat = Timer.periodic(const Duration(milliseconds: 180), (_) {
      if (_currentMove != null) widget.onDirection(_currentMove);
    });
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  void _updateDirection(Offset p) {
    const dead = 10.0;
    final r = p.distance;
    if (r < dead) {
      _currentMove = null;
      widget.onDirection(null);
      return;
    }
    final ang = atan2(p.dy, p.dx); // radians; right=0, up=-pi/2
    // Snap to 4 dirs
    final dirs = [
      (-pi/4) .. toString(), // not used; just a placeholder
    ];
    String m;
    if (ang > -3*pi/4 && ang <= -pi/4) {
      // Up
      m = 'U';
    } else if (ang > pi/4 && ang <= 3*pi/4) {
      // Down
      m = 'D';
    } else if (ang > -pi/4 && ang <= pi/4) {
      // Right
      m = widget.useFB ? 'F' : 'R';
    } else {
      // Left
      m = widget.useFB ? 'B' : 'L';
    }
    if (widget.prime) m = "$m'";
    _currentMove = m;
    widget.onDirection(m);
  }

  @override
  Widget build(BuildContext context) {
    const size = 120.0;
    const knobRadius = 24.0;
    return GestureDetector(
      onPanStart: (d) {
        RenderBox box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(d.globalPosition);
        _knob = local - Offset(size/2, size/2);
        // clamp radius
        _knob = _knob * (min(_knob.distance, size/2 - knobRadius) / max(_knob.distance, 1));
        _updateDirection(_knob);
        _startRepeat();
        setState(() {});
      },
      onPanUpdate: (d) {
        _knob += d.delta;
        // clamp to circle
        final r = _knob.distance;
        final maxR = size/2 - knobRadius;
        if (r > maxR) _knob = _knob * (maxR / r);
        _updateDirection(_knob);
        setState(() {});
      },
      onPanEnd: (_) {
        _knob = Offset.zero;
        _currentMove = null;
        _stopRepeat();
        widget.onDirection(null);
        setState(() {});
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // base
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ),
            // knob
            Positioned(
              left: size/2 + _knob.dx - knobRadius,
              top:  size/2 + _knob.dy - knobRadius,
              child: Container(
                width: knobRadius*2,
                height: knobRadius*2,
                decoration: const BoxDecoration(
                  color: Colors.white70,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
