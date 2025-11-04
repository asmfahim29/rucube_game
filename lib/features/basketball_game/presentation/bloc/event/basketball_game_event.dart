import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class BasketballGameEvent {}

class GameStarted extends BasketballGameEvent {}

class ResetGame extends BasketballGameEvent {} // FIX: New event for resetting game

class Tick extends BasketballGameEvent {
  final double dt;
  Tick(this.dt);
}

class ShotBegin extends BasketballGameEvent {
  final Offset p;
  ShotBegin(this.p);
}

class ShotDrag extends BasketballGameEvent {
  final Offset p;
  ShotDrag(this.p);
}

class ShotRelease extends BasketballGameEvent {
  final Offset p;
  ShotRelease(this.p);
}

class Scored extends BasketballGameEvent {}

class Missed extends BasketballGameEvent {}

class HideScoreFlash extends BasketballGameEvent {}

class ShowLevelSplash extends BasketballGameEvent {
  final int level;
  ShowLevelSplash(this.level);
}

class HideLevelSplash extends BasketballGameEvent {}

class SpawnScoreAnim extends BasketballGameEvent {
  final double x;
  final double y;
  SpawnScoreAnim(this.x, this.y);
}
