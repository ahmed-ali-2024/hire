import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recruitment_session_entity.dart';
import '../repositories/recruitment_repository.dart';

class GetSessionsParams {
  final String userId;
  const GetSessionsParams({required this.userId});
}

class GetSessionsUseCase implements UseCase<List<RecruitmentSessionEntity>, GetSessionsParams> {
  final RecruitmentRepository repository;
  GetSessionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RecruitmentSessionEntity>>> call(GetSessionsParams params) async {
    return await repository.getSessions(params.userId);
  }
}
