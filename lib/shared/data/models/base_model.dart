import 'package:hire/core/usecases/base_entity.dart';

abstract class BaseModel<T extends BaseEntity> extends BaseEntity {
  const BaseModel();

  T toEntity();
}
