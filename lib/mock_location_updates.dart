import 'package:flutter/services.dart';

class MockLocationUpdates {
  static const EventChannel _eventChannel =
      EventChannel('fluttermocklocation_updates');

  static Stream<Map<String, double>> get locationStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return Map<String, double>.from(event);
    });
  }
}
