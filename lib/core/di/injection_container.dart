import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/environment_config.dart';
import '../services/platform_service.dart';
import '../services/responsive_service.dart';
import '../services/connectivity_service.dart';
import '../services/cache_service.dart';
import '../services/persistent_cache_service.dart';
import '../services/ai/aiml_service.dart';
import '../services/ai/featherless_service.dart';
import '../services/band/band_service.dart';
import '../services/parser/cv_parser_service.dart';
import '../l10n/locale_cubit.dart';
import '../theme/theme_cubit.dart';

// Auth Features
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/check_auth_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Settings Features
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_api_keys_usecase.dart';
import '../../features/settings/domain/usecases/save_api_keys_usecase.dart';

// Recruitment Features
import '../../features/recruitment/data/datasources/recruitment_remote_datasource.dart';
import '../../features/recruitment/data/repositories/recruitment_repository_impl.dart';
import '../../features/recruitment/domain/repositories/recruitment_repository.dart';
import '../../features/recruitment/domain/usecases/create_session_usecase.dart';
import '../../features/recruitment/domain/usecases/get_sessions_usecase.dart';
import '../../features/recruitment/domain/usecases/get_session_by_id_usecase.dart';
import '../../features/recruitment/domain/usecases/get_candidates_usecase.dart';
import '../../features/recruitment/domain/usecases/upload_cvs_usecase.dart';
import '../../features/recruitment/presentation/cubit/recruitment_cubit.dart';
import '../../features/recruitment/presentation/cubit/file_upload_cubit.dart';
import '../../features/recruitment/presentation/cubit/session_detail_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core Services
  sl.registerLazySingleton<PlatformService>(() => const PlatformServiceImpl());
  sl.registerLazySingleton<ResponsiveService>(() => const ResponsiveServiceImpl());
  sl.registerLazySingleton<ConnectivityService>(() => const ConnectivityServiceImpl());
  sl.registerLazySingleton<CacheService>(() => CacheServiceImpl());
  sl.registerLazySingleton<PersistentCacheService>(() => PersistentCacheServiceImpl());
  
  sl.registerLazySingleton<AimlService>(() => AimlServiceImpl(
        baseUrl: EnvironmentConfig.instance.aimlBaseUrl,
      ));
  sl.registerLazySingleton<FeatherlessService>(() => FeatherlessServiceImpl(
        baseUrl: EnvironmentConfig.instance.featherlessBaseUrl,
      ));
  sl.registerLazySingleton<BandService>(() => BandServiceImpl(
        baseUrl: EnvironmentConfig.instance.bandApiUrl,
        supabaseClient: sl(),
      ));
  sl.registerLazySingleton<CVParserService>(() => const CVParserServiceImpl());

  // App-Level Cubits
  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => LocaleCubit());

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
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  // Features - Recruitment
  sl.registerFactory(() => RecruitmentCubit(
        createSessionUseCase: sl(),
        getSessionsUseCase: sl(),
      ));
  sl.registerFactory(() => FileUploadCubit(
        uploadCVsUseCase: sl(),
      ));
  sl.registerFactory(() => SessionDetailCubit(
        getSessionByIdUseCase: sl(),
        getCandidatesUseCase: sl(),
      ));
  sl.registerLazySingleton(() => CreateSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionsUseCase(sl()));
  sl.registerLazySingleton(() => GetSessionByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCandidatesUseCase(sl()));
  sl.registerLazySingleton(() => UploadCVsUseCase(sl()));
  sl.registerLazySingleton<RecruitmentRepository>(() => RecruitmentRepositoryImpl(
        remoteDataSource: sl(),
        connectivityService: sl(),
        cvParserService: sl(),
      ));
  sl.registerLazySingleton<RecruitmentRemoteDataSource>(() => RecruitmentRemoteDataSourceImpl(sl()));

  // Features - Settings
  sl.registerLazySingleton(() => GetApiKeysUseCase(sl()));
  sl.registerLazySingleton(() => SaveApiKeysUseCase(sl()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()));
  sl.registerLazySingleton<SettingsRemoteDataSource>(() => SettingsRemoteDataSourceImpl(sl()));

  // External
  sl.registerLazySingleton(() => Supabase.instance.client);
}
