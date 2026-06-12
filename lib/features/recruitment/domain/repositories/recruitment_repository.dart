import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import '../../../core/error/failures.dart';
import '../entities/recruitment_session_entity.dart';
import '../entities/candidate_entity.dart';

abstract class RecruitmentRepository {
  Future<Either<Failure, RecruitmentSessionEntity>> createSession({
    required String userId,
    required String jobTitle,
    required String jobDescription,
  });

  Future<Either<Failure, List<RecruitmentSessionEntity>>> getSessions(String userId);

  Future<Either<Failure, RecruitmentSessionEntity>> getSessionById(String id);

  Future<Either<Failure, Unit>> updateSessionStatus(String id, SessionStatus status);

  Future<Either<Failure, Unit>> updateSessionBandRoom(String id, String bandRoomId);

  Future<Either<Failure, List<CandidateEntity>>> uploadCVs({
    required String sessionId,
    required List<PlatformFile> files,
  });

  Future<Either<Failure, List<CandidateEntity>>> getCandidates(String sessionId);

  Future<Either<Failure, Unit>> updateCandidateStatus(String candidateId, CandidateStatus status);

  Future<Either<Failure, Unit>> updateCandidateScore(String candidateId, double score);
}
