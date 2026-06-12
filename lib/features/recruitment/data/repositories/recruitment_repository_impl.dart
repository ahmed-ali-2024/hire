import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/parser/cv_parser_service.dart';
import '../../domain/entities/recruitment_session_entity.dart';
import '../../domain/entities/candidate_entity.dart';
import '../../domain/repositories/recruitment_repository.dart';
import '../datasources/recruitment_remote_datasource.dart';
import '../models/candidate_model.dart';

class RecruitmentRepositoryImpl implements RecruitmentRepository {
  final RecruitmentRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;
  final CVParserService cvParserService;

  RecruitmentRepositoryImpl({
    required this.remoteDataSource,
    required this.connectivityService,
    required this.cvParserService,
  });

  @override
  Future<Either<Failure, RecruitmentSessionEntity>> createSession({
    required String userId,
    required String jobTitle,
    required String jobDescription,
  }) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final session = await remoteDataSource.createSession(
        userId: userId,
        jobTitle: jobTitle,
        jobDescription: jobDescription,
      );
      return Right(session);
    } catch (e) {
      AppLogger.instance.e('CreateSession failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecruitmentSessionEntity>>> getSessions(String userId) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final sessions = await remoteDataSource.getSessions(userId);
      return Right(sessions);
    } catch (e) {
      AppLogger.instance.e('GetSessions failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecruitmentSessionEntity>> getSessionById(String id) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final session = await remoteDataSource.getSessionById(id);
      return Right(session);
    } catch (e) {
      AppLogger.instance.e('GetSessionById failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSessionStatus(String id, SessionStatus status) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      await remoteDataSource.updateSessionStatus(id, status.name);
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('UpdateSessionStatus failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSessionBandRoom(String id, String bandRoomId) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      await remoteDataSource.updateSessionBandRoom(id, bandRoomId);
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('UpdateSessionBandRoom failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CandidateEntity>>> uploadCVs({
    required String sessionId,
    required List<PlatformFile> files,
  }) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final List<CandidateEntity> candidates = [];
      for (final file in files) {
        // Real PDF parsing using CVParserService
        final cvText = await cvParserService.parseFile(file);
        final name = cvParserService.extractCandidateName(cvText);
        
        final candidate = CandidateModel(
          id: const Uuid().v4(),
          sessionId: sessionId,
          name: name == 'Unknown Candidate' ? file.name.split('.').first : name,
          cvText: cvText.isEmpty ? 'No readable content extracted' : cvText,
          fileName: file.name,
          status: CandidateStatus.pending,
          createdAt: DateTime.now(),
        );
        await remoteDataSource.addCandidate(candidate);
        candidates.add(candidate);
      }
      return Right(candidates);
    } catch (e) {
      AppLogger.instance.e('UploadCVs failed', e);
      return Left(ParserFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CandidateEntity>>> getCandidates(String sessionId) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final candidates = await remoteDataSource.getCandidates(sessionId);
      return Right(candidates);
    } catch (e) {
      AppLogger.instance.e('GetCandidates failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCandidateStatus(String candidateId, CandidateStatus status) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      await remoteDataSource.updateCandidateStatus(candidateId, status.name);
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('UpdateCandidateStatus failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCandidateScore(String candidateId, double score) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      await remoteDataSource.updateCandidateScore(candidateId, score);
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('UpdateCandidateScore failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
