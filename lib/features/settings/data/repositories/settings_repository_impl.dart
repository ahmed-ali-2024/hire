import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../domain/entities/api_keys_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/api_keys_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Unit>> saveApiKeys({
    required String userId,
    required String aimlApiKey,
    required String featherlessKey,
    required String bandApiKey,
    required String bandApiUrl,
  }) async {
    try {
      final keys = ApiKeysModel(
        id: const Uuid().v4(),
        userId: userId,
        aimlApiKey: aimlApiKey,
        featherlessKey: featherlessKey,
        bandApiKey: bandApiKey,
        bandApiUrl: bandApiUrl,
        updatedAt: DateTime.now(),
      );
      await remoteDataSource.saveApiKeys(keys);
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('SaveApiKeys failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApiKeysEntity>> getApiKeys(String userId) async {
    try {
      final keys = await remoteDataSource.getApiKeys(userId);
      return Right(keys);
    } catch (e) {
      AppLogger.instance.e('GetApiKeys failed', e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
