import 'package:flame/components.dart';

class FieldComponent extends SpriteComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('field_bg.png');
    size = gameRef.size;
    position = Vector2.zero();
  }
}
