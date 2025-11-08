import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rucube_game/features/kickfree_2D/domain/usecases/calculate_trajectory_usecase.dart';
import 'package:rucube_game/features/kickfree_2D/domain/usecases/start_kick_usecase.dart';

import '/features/kickfree_2D/presentation/bloc/event/kickfree_2D_event.dart';
import '/features/kickfree_2D/presentation/bloc/state/kickfree_2D_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class Kickfree2dBloc extends Bloc<Kickfree2dEvent, Kickfree2dState> {
  final StartKick startKick;
  final CalculateTrajectory calculateTrajectory;

  Kickfree2dBloc({required this.startKick, required this.calculateTrajectory})
      : super(GameInitial()) {
    on<PrepareKick>((event, emit) => emit(GameReady()));
    on<KickTaken>((event, emit) async {
      emit(KickInProgress());
      await startKick();
      emit(KickComplete());
    });
  }
}

