import 'package:flutter/foundation.dart';

abstract class PlatformService {
  bool get isWeb;
  bool get isAndroid;
  bool get isIOS;
}

class PlatformServiceImpl implements PlatformService {
  @override
  bool get isWeb => kIsWeb;

  @override
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}
