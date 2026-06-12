import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/api_keys_entity.dart';
import '../repositories/settings_repository.dart';

class GetApiKeysParams {
  final String userId;
  const GetApiKeysParams({required this.userId});
}

class GetApiKeysUseCase implements UseCase<ApiKeysEntity, GetApiKeysParams> {
  final SettingsRepository repository;
  GetApiKeysUseCase(this.repository);

  @override
  Future<Either<Failure, ApiKeysEntity>> call(GetApiKeysParams params) async {
    return await repository.getApiKeys(params.userId);
  }
}
