import 'package:equatable/equatable.dart';

import '/features/kickfree_2D/domain/entities/kickfree_2D.dart';

/// State for Kickfree2d
abstract class Kickfree2dState {}

class GameInitial extends Kickfree2dState {}

class GameReady extends Kickfree2dState {}

class KickInProgress extends Kickfree2dState {}

class KickComplete extends Kickfree2dState {}