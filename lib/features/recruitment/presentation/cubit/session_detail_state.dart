import 'package:equatable/equatable.dart';
import '../../domain/entities/recruitment_session_entity.dart';
import '../../domain/entities/candidate_entity.dart';

abstract class SessionDetailState extends Equatable {
  const SessionDetailState();

  @override
  List<Object?> get props => [];
}

class SessionDetailInitial extends SessionDetailState {}

class SessionDetailLoading extends SessionDetailState {}

class SessionDetailLoaded extends SessionDetailState {
  final RecruitmentSessionEntity session;
  final List<CandidateEntity> candidates;

  const SessionDetailLoaded({
    required this.session,
    required this.candidates,
  });

  @override
  List<Object?> get props => [session, candidates];
}

class SessionDetailError extends SessionDetailState {
  final String message;

  const SessionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
