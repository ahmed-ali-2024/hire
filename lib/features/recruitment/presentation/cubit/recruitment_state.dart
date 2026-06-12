part of 'recruitment_cubit.dart';

abstract class RecruitmentState extends Equatable {
  const RecruitmentState();

  @override
  List<Object?> get props => [];
}

class RecruitmentInitial extends RecruitmentState {}

class RecruitmentLoading extends RecruitmentState {}

class RecruitmentLoaded extends RecruitmentState {
  final List<RecruitmentSessionEntity> sessions;
  const RecruitmentLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class RecruitmentError extends RecruitmentState {
  final String message;
  const RecruitmentError(this.message);

  @override
  List<Object?> get props => [message];
}
