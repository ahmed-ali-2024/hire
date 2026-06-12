import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hire/core/di/injection_container.dart' as di;
import 'package:hire/features/recruitment/presentation/cubit/recruitment_cubit.dart';
import 'package:hire/features/recruitment/presentation/cubit/file_upload_cubit.dart';
import 'package:hire/features/auth/presentation/cubit/auth_cubit.dart';

class MockLocalStorage extends LocalStorage {
  const MockLocalStorage();
  @override
  Future<void> initialize() async {}
  @override
  Future<String?> accessToken() async => null;
  @override
  Future<void> removePersistedSession() async {}
  @override
  Future<void> persistSession(String session) async {}
  @override
  Future<bool> hasAccessToken() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Check dependency injection resolutions', () async {
    // Initialize Supabase with dummy config and MockLocalStorage for test
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'placeholder_anon_key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: MockLocalStorage(),
      ),
    );

    // Initialize DI
    await di.init();

    final sl = GetIt.instance;

    // Try resolving cubits
    expect(sl.isRegistered<AuthCubit>(), isTrue);
    expect(sl.isRegistered<RecruitmentCubit>(), isTrue);
    expect(sl.isRegistered<FileUploadCubit>(), isTrue);

    final authCubit = sl<AuthCubit>();
    final recruitmentCubit = sl<RecruitmentCubit>();
    final fileUploadCubit = sl<FileUploadCubit>();

    expect(authCubit, isNotNull);
    expect(recruitmentCubit, isNotNull);
    expect(fileUploadCubit, isNotNull);

    print('DI resolved successfully!');
  });
}
