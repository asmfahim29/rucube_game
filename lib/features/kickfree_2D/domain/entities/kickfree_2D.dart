import 'package:equatable/equatable.dart';

/// Kickfree2d entity - Represents kickfree_2D in the business domain
class Kickfree2d extends Equatable {
  final int id;
  // Add your entity properties here

  const Kickfree2d({
    required this.id,

  });

  @override
  List<Object?> get props => [id];
}
