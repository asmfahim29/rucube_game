import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

/// StadiumBackgroundComponent
/// Realistic parallax background with sky, audience, and grass layers.
/// Gives a 2.5D depth illusion when the camera moves horizontally.
class StadiumBackgroundComponent extends ParallaxComponent {
  StadiumBackgroundComponent();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    /// Load layers
    parallax = await game.loadParallax(
      [
        ParallaxImageData('football/stadium_sky.jpg'),
        ParallaxImageData('football/audience_wave.jpg'),
        ParallaxImageData('football/stadium.jpg'),
        ParallaxImageData('football/ground_grass.jpg'),
      ],
      baseVelocity: Vector2(2, 0),
      velocityMultiplierDelta: Vector2(1.8, 0),
      repeat: ImageRepeat.repeatX,
    );
  }
}
