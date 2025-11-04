import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class BasketballGameEvent {}

// lifecycle/tick/shoot you already have…
class GameStarted extends BasketballGameEvent {}
class Tick extends BasketballGameEvent { final double dt; Tick(this.dt); }
class ShotBegin extends BasketballGameEvent { final Offset p; ShotBegin(this.p); }
class ShotDrag extends BasketballGameEvent { final Offset p; ShotDrag(this.p); }
class ShotRelease extends BasketballGameEvent { final Offset p; ShotRelease(this.p); }

// NEW scoring/lives/levels
class Scored extends BasketballGameEvent {}               // called once when ball crosses rim downward
class Missed extends BasketballGameEvent {}               // called when ball falls below floor
class HideScoreFlash extends BasketballGameEvent {}       // clears transient center-flash
class ShowLevelSplash extends BasketballGameEvent {       // show “Level N”
  final int level;
  ShowLevelSplash(this.level);
}
class HideLevelSplash extends BasketballGameEvent {}
// (optional) spawn a quick ghost ball animation
class SpawnScoreAnim extends BasketballGameEvent {
  final double x; final double y;
  SpawnScoreAnim(this.x, this.y);
}
