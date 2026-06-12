import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/recruitment/data/datasources/recruitment_remote_datasource.dart';
import '../../features/recruitment/data/repositories/recruitment_repository_impl.dart';
import '../../features/recruitment/domain/repositories/recruitment_repository.dart';
import '../../features/recruitment/domain/usecases/create_session_usecase.dart';
import '../../features/recruitment/domain/usecases/get_sessions_usecase.dart';
import '../../features/recruitment/domain/usecases/upload_cvs_usecase.dart';
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_api_keys_usecase.dart';
import '../../features/settings/domain/usecases/save_api_keys_usecase.dart';
import '../services/platform_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core Services
  sl.registerLazySingleton<PlatformService>(() => PlatformServiceImpl());

  // Features - Auth
  sl.registerLazySingleton(() => AuthCubit(
        signInUseCase: sl(),
        signUpUseCase: sl(),
        signOutUseCase: sl(),
        checkAuthUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  // Features - Recruitment
  sl.registerLazySingleton(() => CreateSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
  sl.registerLazySingleton(() => UploadCVsUseCase(sl()));
  sl.registerLazySingleton<RecruitmentRepository>(() => RecruitmentRepositoryImpl(sl()));
  sl.registerLazySingleton<RecruitmentRemoteDataSource>(() => RecruitmentRemoteDataSourceImpl(sl()));

  // Features - Settings
  sl.registerLazySingleton(() => GetApiKeysUseCase(sl()));
  sl.registerLazySingleton(() => SaveApiKeysUseCase(sl()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));
  sl.registerLazySingleton<SettingsRemoteDataSource>(() => SettingsRemoteDataSourceImpl(sl()));

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
