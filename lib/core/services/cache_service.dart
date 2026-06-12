abstract class CacheService {
  void put(String key, dynamic value);
  dynamic get(String key);
  void remove(String key);
  void clear();
}

class CacheServiceImpl implements CacheService {
  final Map<String, dynamic> _cache = {};

  @override
  void put(String key, dynamic value) {
    _cache[key] = value;
  }

  @override
  dynamic get(String key) {
    return _cache[key];
  }

  @override
  void remove(String key) {
    _cache.remove(key);
  }

  @override
  void clear() {
    _cache.clear();
  }
}
