import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class SaveApiKeysParams {
  final String userId;
  final String aimlKey;
  final String featherlessKey;
  final String bandKey;
  final String bandUrl;

  const SaveApiKeysParams({
    required this.userId,
    required this.aimlKey,
    required this.featherlessKey,
    required this.bandKey,
    required this.bandUrl,
  });
}

class SaveApiKeysUseCase implements UseCase<Unit, SaveApiKeysParams> {
  final SettingsRepository repository;
  SaveApiKeysUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SaveApiKeysParams params) async {
    return await repository.saveApiKeys(
      userId: params.userId,
      aimlApiKey: params.aimlKey,
      featherlessKey: params.featherlessKey,
      bandApiKey: params.bandKey,
      bandApiUrl: params.bandUrl,
    );
  }
}
