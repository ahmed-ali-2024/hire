import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/candidate_entity.dart';
import '../repositories/recruitment_repository.dart';

class GetCandidatesParams {
  final String sessionId;
  const GetCandidatesParams(this.sessionId);
}

class GetCandidatesUseCase implements UseCase<List<CandidateEntity>, GetCandidatesParams> {
  final RecruitmentRepository repository;

  GetCandidatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<CandidateEntity>>> call(GetCandidatesParams params) async {
    return await repository.getCandidates(params.sessionId);
  }
}
