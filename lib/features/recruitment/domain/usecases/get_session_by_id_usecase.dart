import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/recruitment_session_entity.dart';
import '../repositories/recruitment_repository.dart';

class GetSessionByIdParams {
  final String id;
  const GetSessionByIdParams(this.id);
}

class GetSessionByIdUseCase implements UseCase<RecruitmentSessionEntity, GetSessionByIdParams> {
  final RecruitmentRepository repository;

  GetSessionByIdUseCase(this.repository);

  @override
  Future<Either<Failure, RecruitmentSessionEntity>> call(GetSessionByIdParams params) async {
    return await repository.getSessionById(params.id);
  }
}
