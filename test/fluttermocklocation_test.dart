import 'package:flutter_test/flutter_test.dart';
import 'package:fluttermocklocation/fluttermocklocation.dart';
import 'package:fluttermocklocation/fluttermocklocation_platform_interface.dart';
import 'package:fluttermocklocation/fluttermocklocation_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFluttermocklocationPlatform
    with MockPlatformInterfaceMixin
    implements FluttermocklocationPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final FluttermocklocationPlatform initialPlatform =
      FluttermocklocationPlatform.instance;

  test('$MethodChannelFluttermocklocation is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFluttermocklocation>());
  });

  test('getPlatformVersion', () async {
    Fluttermocklocation fluttermocklocationPlugin = Fluttermocklocation();
    MockFluttermocklocationPlatform fakePlatform =
        MockFluttermocklocationPlatform();
    FluttermocklocationPlatform.instance = fakePlatform;

    expect(await fluttermocklocationPlugin.getPlatformVersion(), '42');
  });
}
