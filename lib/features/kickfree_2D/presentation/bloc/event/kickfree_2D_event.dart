import 'package:equatable/equatable.dart';

/// Events for Kickfree2d
abstract class Kickfree2dEvent {}

class PrepareKick extends Kickfree2dEvent {}

class KickTaken extends Kickfree2dEvent {}
