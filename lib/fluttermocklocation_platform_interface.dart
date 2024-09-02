import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fluttermocklocation_method_channel.dart';

abstract class FluttermocklocationPlatform extends PlatformInterface {
  /// Constructs a FluttermocklocationPlatform.
  FluttermocklocationPlatform() : super(token: _token);

  static final Object _token = Object();

  static FluttermocklocationPlatform _instance =
      MethodChannelFluttermocklocation();

  /// The default instance of [FluttermocklocationPlatform] to use.
  ///
  /// Defaults to [MethodChannelFluttermocklocation].
  static FluttermocklocationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FluttermocklocationPlatform] when
  /// they register themselves.
  static set instance(FluttermocklocationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  // Definisci qui il nuovo metodo astratto
  Future<void> updateMockLocation(double latitude, double longitude,
      {double altitude = 0, int delay = 5000});
}
