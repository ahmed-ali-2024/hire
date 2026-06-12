import '../../../core/usecases/base_entity.dart';

class UserEntity extends BaseEntity {
  final String id;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, createdAt];
}
