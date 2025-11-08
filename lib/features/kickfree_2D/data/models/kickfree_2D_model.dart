import '/features/kickfree_2D/domain/entities/kickfree_2D.dart';

/// Model class for Kickfree2d that extends the domain entity
class Kickfree2dModel extends Kickfree2d {
  const Kickfree2dModel({
    required super.id,
  });

  /// Create a Kickfree2dModel from JSON
  factory Kickfree2dModel.fromJson(Map<String, dynamic> json) {
    return Kickfree2dModel(
      id: json['id'] as int,
    
    );
  }

  /// Convert Kickfree2dModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
     
    };
  }
}
