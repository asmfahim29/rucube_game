import 'package:flame/game.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/field_component.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/football_component.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/goalkeeper_component.dart';
import 'package:rucube_game/features/kickfree_2D/presentation/widgets/player_component.dart';


class KickfreeGame extends FlameGame {
  late final FieldComponent field;
  late final FootballComponent ball;
  late final PlayerComponent player;
  late final GoalkeeperComponent keeper;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    field = FieldComponent();
    ball = FootballComponent();
    player = PlayerComponent(ball);
    keeper = GoalkeeperComponent();

    add(field);
    add(ball);
    add(player);
    add(keeper);
  }

  void resetForNewKick() {
    ball.reset();
    player.reset();
  }
}
