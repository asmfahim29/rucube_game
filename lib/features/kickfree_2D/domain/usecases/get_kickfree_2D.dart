import 'package:dartz/dartz.dart';

import '/core/error/failures.dart';
import '/core/usecases/usecase.dart';
import '/features/kickfree_2D/domain/entities/kickfree_2D.dart';
import '/features/kickfree_2D/domain/repositories/kickfree_2D_repository.dart';

/// Use case for getting kickfree_2D
// class GetKickfree2d implements UseCase<List<Kickfree2d>, NoParams> {
//   final Kickfree2dRepository _repository;
//
//   GetKickfree2d(this._repository);
//
//   @override
//   Future<Either<Failure, List<Kickfree2d>>> call(NoParams params) async {
//     return await _repository.loadBestScore();
//   }
// }
