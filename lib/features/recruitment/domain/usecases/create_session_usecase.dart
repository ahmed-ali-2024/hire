import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recruitment_session_entity.dart';
import '../repositories/recruitment_repository.dart';

class CreateSessionParams {
  final String userId;
  final String jobTitle;
  final String jobDescription;

  const CreateSessionParams({
    required this.userId,
    required this.jobTitle,
    required this.jobDescription,
  });
}

class CreateSessionUseCase implements UseCase<RecruitmentSessionEntity, CreateSessionParams> {
  final RecruitmentRepository repository;
  CreateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, RecruitmentSessionEntity>> call(CreateSessionParams params) async {
    return await repository.createSession(
      userId: params.userId,
      jobTitle: params.jobTitle,
      jobDescription: params.jobDescription,
    );
  }
}
