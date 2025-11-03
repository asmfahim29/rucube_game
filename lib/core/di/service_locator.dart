import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rucube_game/features/basketball_game/data/repositories/basketball_game_repository_impl.dart';
import 'package:rucube_game/features/basketball_game/domain/repositories/basketball_game_repository.dart';
import 'package:rucube_game/features/basketball_game/domain/usecases/get_basketball_game.dart';
import 'package:rucube_game/features/basketball_game/presentation/bloc/basketball_game_bloc.dart';
import 'package:rucube_game/features/puzzle/data/repositories/puzzle_repository_impl.dart';
import 'package:rucube_game/features/puzzle/domain/repositories/puzzle_repository.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/apply_move.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/check_solved.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/get_puzzle.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/next_level.dart';
import 'package:rucube_game/features/puzzle/domain/usecases/scramble_puzzle.dart';
import 'package:rucube_game/features/puzzle/presentation/bloc/game_bloc.dart';
import '/core/network/api_client.dart';
import '/core/network/network_info.dart';
import '/core/utils/preferences_helper.dart';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ------------------ 🌐 External ------------------
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ------------------ 🧠 Core ------------------
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(connectivity: sl()),
  );

  sl.registerLazySingleton<PrefHelper>(() => PrefHelper.instance);

  sl.registerLazySingleton<ApiClient>(
        () => ApiClient(dio: sl(), networkInfo: sl(), prefHelper: sl()),
  );

  // ------------------ 🧩 Puzzle Feature ------------------

  // Repository
  sl.registerLazySingleton<PuzzleRepository>(() => PuzzleRepositoryImpl());

  // UseCases
  sl.registerLazySingleton(() => InitPuzzle(sl()));
  sl.registerLazySingleton(() => ApplyMove(sl()));
  sl.registerLazySingleton(() => ScramblePuzzle(sl()));
  sl.registerLazySingleton(() => CheckSolved(sl()));
  sl.registerLazySingleton(() => NextLevel(sl()));

  // BLoC (factory = new instance each time)
  sl.registerFactory(
        () => RucubeGameBloc(
      initPuzzle: sl(),
      applyMove: sl(),
      scramblePuzzle: sl(),
      checkSolved: sl(),
      nextLevel: sl(),
      renderStream: (sl<PuzzleRepository>() as PuzzleRepositoryImpl).render$(),
    ),
  );

  // ------------------ 🧩 Basket-Ball Feature ------------------

  // Repository
  sl.registerLazySingleton<BasketballGameRepository>(() => BasketballGameRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl(),));

  //UseCases
  sl.registerLazySingleton(() => GetBasketballGame(sl()));

  // BLoC (facloc( = new instanceloc(h time)
  sl.registerFactory(() => BasketballGameBloc(420));


}
