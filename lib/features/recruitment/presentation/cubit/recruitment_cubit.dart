import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recruitment_session_entity.dart';
import '../../domain/usecases/create_session_usecase.dart';
import '../../domain/usecases/get_sessions_usecase.dart';

part 'recruitment_state.dart';

class RecruitmentCubit extends Cubit<RecruitmentState> {
  final CreateSessionUseCase createSessionUseCase;
  final GetSessionsUseCase getSessionsUseCase;

  RecruitmentCubit({
    required this.createSessionUseCase,
    required this.getSessionsUseCase,
  }) : super(RecruitmentInitial());

  Future<void> loadSessions(String userId) async {
    emit(RecruitmentLoading());
    final result = await getSessionsUseCase(GetSessionsParams(userId: userId));
    result.fold(
      (failure) => emit(RecruitmentError(failure.message)),
      (sessions) => emit(RecruitmentLoaded(sessions)),
    );
  }

  Future<void> createSession({
    required String userId,
    required String jobTitle,
    required String jobDescription,
  }) async {
    emit(RecruitmentLoading());
    final result = await createSessionUseCase(CreateSessionParams(
      userId: userId,
      jobTitle: jobTitle,
      jobDescription: jobDescription,
    ));
    result.fold(
      (failure) => emit(RecruitmentError(failure.message)),
      (_) => loadSessions(userId),
    );
  }
}
