import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/environment_config.dart';
import 'core/di/injection_container.dart' as di;
import 'core/logger/app_logger.dart';
import 'core/theme/theme_cubit.dart';
import 'core/l10n/locale_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize EnvironmentConfig to read .env .
  await EnvironmentConfig.instance.init();

  // 2. Initialize Supabase with env configuration
  await Supabase.initialize(
    url: EnvironmentConfig.instance.supabaseUrl,
    publishableKey: EnvironmentConfig.instance.supabaseAnonKey,
  );

  // 3. Initialize HydratedBloc Storage
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  // 4. Initialize Dependency Injection
  await di.init();

  // 5. Global Error Handling
  FlutterError.onError = (details) {
    AppLogger.instance.e(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
  };

  runApp(const HireApp());
}

class HireApp extends StatelessWidget {
  const HireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuth()),
        BlocProvider(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider(create: (_) => di.sl<LocaleCubit>()),
      ],
      child: const AppView(),
    );
  }
}
