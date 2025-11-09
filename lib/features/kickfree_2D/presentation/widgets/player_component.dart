import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/football_component.dart';

class PlayerComponent extends PositionComponent with DragCallbacks {
  final FootballComponent ball;
  Vector2 _dragStart = Vector2.zero();
  Vector2 _dragEnd = Vector2.zero();

  PlayerComponent(this.ball);

  @override
  bool onDragStart(DragStartEvent event) {
    _dragStart = event.localPosition;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    _dragEnd = event.localEndPosition;
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    final dragVector = _dragStart - _dragEnd;
    final power = dragVector.length.clamp(0, 300).toDouble();
    ball.isInAir;
    return true;
  }

  void reset() {}
}
