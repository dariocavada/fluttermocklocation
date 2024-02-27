import 'fluttermocklocation_platform_interface.dart';

class Fluttermocklocation {
  Future<String?> getPlatformVersion() {
    return FluttermocklocationPlatform.instance.getPlatformVersion();
  }

  Future<void> updateMockLocation(double latitude, double longitude) {
    return FluttermocklocationPlatform.instance
        .updateMockLocation(latitude, longitude);
  }
}
