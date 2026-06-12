import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  AuthRepositoryImpl(this.remoteDataSource, this.connectivityService);

  @override
  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final user = await remoteDataSource.signInWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      AppLogger.instance.e('SignIn failed', e);
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String email,
    required String password,
  }) async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      final user = await remoteDataSource.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } catch (e) {
      AppLogger.instance.e('SignUp failed', e);
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (!await connectivityService.isConnected) {
      return const Left(NoConnectionFailure());
    }
    try {
      await remoteDataSource.signOut();
      return const Right(unit);
    } catch (e) {
      AppLogger.instance.e('SignOut failed', e);
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    // Checking connection is optional here as it checks local session, but safe to do if it hits net.
    // However, getCurrentUser in Supabase reads active session from memory/cache first.
    // So we don't strictly enforce internet block on this one to allow offline startup.
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Right(user);
    } catch (e) {
      AppLogger.instance.e('GetCurrentUser failed', e);
      return Left(AuthFailure(e.toString()));
    }
  }
}
