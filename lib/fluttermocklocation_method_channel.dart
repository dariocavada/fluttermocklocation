import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fluttermocklocation_platform_interface.dart';

/// An implementation of [FluttermocklocationPlatform] that uses method channels.
class MethodChannelFluttermocklocation extends FluttermocklocationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fluttermocklocation');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Aggiunge un nuovo metodo per aggiornare la posizione fittizia.
  Future<void> updateMockLocation(double latitude, double longitude) async {
    try {
      await methodChannel.invokeMethod('updateMockLocation', {
        'latitude': latitude,
        'longitude': longitude,
      });
    } on PlatformException catch (e) {
      throw 'Unable to update mock location: ${e.message}';
    }
  }
}
