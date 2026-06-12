import 'package:hydrated_bloc/hydrated_bloc.dart';

abstract class PersistentCacheService {
  Future<void> init();
  Future<void> put(String key, String value);
  String? get(String key);
  Future<void> remove(String key);
  Future<void> clear();
}

class PersistentCacheServiceImpl implements PersistentCacheService {
  PersistentCacheServiceImpl();

  @override
  Future<void> init() async {
    // Initialization is handled in main.dart via HydratedBloc.storage
  }

  @override
  Future<void> put(String key, String value) async {
    await HydratedBloc.storage.write(key, value);
  }

  @override
  String? get(String key) {
    final data = HydratedBloc.storage.read(key);
    return data is String ? data : null;
  }

  @override
  Future<void> remove(String key) async {
    await HydratedBloc.storage.delete(key);
  }

  @override
  Future<void> clear() async {
    await HydratedBloc.storage.clear();
  }
}
