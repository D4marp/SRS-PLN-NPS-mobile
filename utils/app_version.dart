import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  AppVersion._();

  static PackageInfo? _cached;

  static Future<PackageInfo> _load() async {
    return _cached ??= await PackageInfo.fromPlatform();
  }

  static Future<String> loadDisplayLabel() async {
    final info = await _load();
    return 'Versi Aplikasi ${info.version}+${info.buildNumber}';
  }
}
