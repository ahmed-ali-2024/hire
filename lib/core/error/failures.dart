import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure([super.message = 'No Internet Connection']);
}

class ParserFailure extends Failure {
  const ParserFailure(super.message, [super.code]);
}

class AgentFailure extends Failure {
  const AgentFailure(super.message, [super.code]);
}
