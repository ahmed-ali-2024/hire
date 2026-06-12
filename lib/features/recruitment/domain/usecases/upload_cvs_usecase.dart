import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/candidate_entity.dart';
import '../repositories/recruitment_repository.dart';

class UploadCVsParams {
  final String sessionId;
  final List<PlatformFile> files;

  const UploadCVsParams({
    required this.sessionId,
    required this.files,
  });
}

class UploadCVsUseCase implements UseCase<List<CandidateEntity>, UploadCVsParams> {
  final RecruitmentRepository repository;
  UploadCVsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CandidateEntity>>> call(UploadCVsParams params) async {
    return await repository.uploadCVs(
      sessionId: params.sessionId,
      files: params.files,
    );
  }
}
