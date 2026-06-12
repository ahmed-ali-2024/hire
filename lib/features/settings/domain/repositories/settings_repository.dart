import 'package:fpdart/fpdart.dart';
import 'package:hire/core/error/failures.dart';
import '../entities/api_keys_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, Unit>> saveApiKeys({
    required String userId,
    required String aimlApiKey,
    required String featherlessKey,
    required String bandApiKey,
    required String bandApiUrl,
  });

  Future<Either<Failure, ApiKeysEntity>> getApiKeys(String userId);
}
