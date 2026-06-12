import 'package:flutter/foundation.dart';

abstract class PlatformService {
  bool get isWeb;
  bool get isAndroid;
  bool get isIOS;
  bool get isMacOS;
  bool get isWindows;
  bool get isLinux;
}

class PlatformServiceImpl implements PlatformService {
  const PlatformServiceImpl();

  @override
  bool get isWeb => kIsWeb;

  @override
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  @override
  bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;
}
