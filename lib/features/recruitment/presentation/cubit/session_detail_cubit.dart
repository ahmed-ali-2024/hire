import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_session_by_id_usecase.dart';
import '../../domain/usecases/get_candidates_usecase.dart';
import 'session_detail_state.dart';

class SessionDetailCubit extends Cubit<SessionDetailState> {
  final GetSessionByIdUseCase getSessionByIdUseCase;
  final GetCandidatesUseCase getCandidatesUseCase;

  SessionDetailCubit({
    required this.getSessionByIdUseCase,
    required this.getCandidatesUseCase,
  }) : super(SessionDetailInitial());

  Future<void> loadSessionDetail(String sessionId) async {
    emit(SessionDetailLoading());

    final sessionResult = await getSessionByIdUseCase(GetSessionByIdParams(sessionId));

    await sessionResult.fold(
      (failure) async => emit(SessionDetailError(failure.message)),
      (session) async {
        final candidatesResult = await getCandidatesUseCase(GetCandidatesParams(sessionId));

        candidatesResult.fold(
          (failure) => emit(SessionDetailError(failure.message)),
          (candidates) => emit(SessionDetailLoaded(
            session: session,
            candidates: candidates,
          )),
        );
      },
    );
  }
}
