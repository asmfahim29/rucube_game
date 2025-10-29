import 'package:flutter_bloc/flutter_bloc.dart';

import '/features/leaderboard/presentation/bloc/event/leaderboard_event.dart';
import '/features/leaderboard/presentation/bloc/state/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(const LeaderboardInitial()) {
 
  }

 

}
