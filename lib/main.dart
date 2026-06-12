import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (Placeholder - will use env variables later)
  await Supabase.initialize(
    url: 'https://fedbxlfyrtwctmyolioq.supabase.co',
    anonKey: 'PLACEHOLDER_ANON_KEY',
  );

  // Initialize DI
  await di.init();

  runApp(const HireApp());
}

class HireApp extends StatelessWidget {
  const HireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuth()),
      ],
      child: const AppView(),
    );
  }
}
