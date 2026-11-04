import 'package:fitone/domain/entities/ring_telemetry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Smart-Ring Native Telemetry Model Tests', () {
    test('Parses raw native EventChannel packet correctly', () {
      final rawMap = {
        'packetId': 1042,
        'timestamp': 1793804800000,
        'deviceId': 'AURA-PRO-9842',
        'sdk': 'SDK_A',
        'heartRate': 74,
        'spo2': 99,
        'hrv': 68,
        'skinTempDelta': 0.15,
        'sleepStage': 'DEEP',
        'stepCount': 8420,
        'batteryLevel': 91,
        'signalQuality': 99,
        'checksum': 'A1B2C3D4',
        'ecgSamples': [0.1, 0.4, 1.2, -0.5, 0.2],
      };

      final telemetry = RingTelemetry.fromMap(rawMap);

      expect(telemetry.packetId, equals(1042));
      expect(telemetry.deviceId, equals('AURA-PRO-9842'));
      expect(telemetry.sdk, equals('SDK_A'));
      expect(telemetry.heartRate, equals(74));
      expect(telemetry.spo2, equals(99));
      expect(telemetry.hrv, equals(68));
      expect(telemetry.skinTempDelta, closeTo(0.15, 0.001));
      expect(telemetry.sleepStage, equals('DEEP'));
      expect(telemetry.stepCount, equals(8420));
      expect(telemetry.batteryLevel, equals(91));
      expect(telemetry.checksum, equals('A1B2C3D4'));
      expect(telemetry.ecgSamples.length, equals(5));
      expect(telemetry.ecgSamples[2], equals(1.2));
    });

    test('Parses RingDevice model correctly', () {
      final map = {
        'id': 'KTX-ULTRA-1049',
        'name': 'KinetixRing Ultra',
        'sdk': 'SDK_B',
        'battery': 94,
        'firmware': 'v1.9.8',
        'rssi': -52,
        'connected': true,
      };

      final device = RingDevice.fromMap(map);
      expect(device.id, equals('KTX-ULTRA-1049'));
      expect(device.name, equals('KinetixRing Ultra'));
      expect(device.sdk, equals('SDK_B'));
      expect(device.battery, equals(94));
      expect(device.isConnected, isTrue);
    });
  });
}
