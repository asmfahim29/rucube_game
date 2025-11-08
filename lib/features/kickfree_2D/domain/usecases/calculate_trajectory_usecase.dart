import 'package:flame/components.dart';

class CalculateTrajectory {
  Future<Vector2> call(Vector2 dragVector, double power) async {
    final normalized = dragVector.normalized();
    final speed = power * 500; // tune multiplier
    return normalized * speed;
  }
}