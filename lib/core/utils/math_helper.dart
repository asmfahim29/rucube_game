import 'dart:math';
import 'package:flutter/painting.dart';

double clamp(double v, double lo, double hi) => v < lo ? lo : (v > hi ? hi : v);
Offset clampToRadius(Offset p, double maxR) {
  final r = p.distance;
  if (r <= maxR || r == 0) return p;
  final s = maxR / r;
  return Offset(p.dx * s, p.dy * s);
}