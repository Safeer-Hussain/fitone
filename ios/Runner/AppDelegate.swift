import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private let controlChannelName = "com.safeer.fitone/ring_control"
  private let telemetryChannelName = "com.safeer.fitone/ring_telemetry"

  private var activeSdk = "SDK_A"
  private var activeDeviceId: String? = "AURA-PRO-9842"
  private var isConnected = true
  private var telemetryIntervalMs: Double = 2.0
  private var packetCounter: Int64 = 1000
  private var baseStepCount: Int64 = 7840

  private var telemetrySink: FlutterEventSink?
  private var telemetryTimer: Timer?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    let controlChannel = FlutterMethodChannel(
      name: controlChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    controlChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }

      switch call.method {
      case "scanDevices":
        let devices: [[String: Any]] = [
          [
            "id": "AURA-PRO-9842",
            "name": "AuraRing Pro v2",
            "sdk": "SDK_A",
            "battery": 88,
            "firmware": "v2.4.1",
            "rssi": -58,
            "connected": (self.activeDeviceId == "AURA-PRO-9842" && self.isConnected)
          ],
          [
            "id": "KTX-ULTRA-1049",
            "name": "KinetixRing Ultra",
            "sdk": "SDK_B",
            "battery": 94,
            "firmware": "v1.9.8",
            "rssi": -52,
            "connected": (self.activeDeviceId == "KTX-ULTRA-1049" && self.isConnected)
          ]
        ]
        result(devices)

      case "connectDevice":
        let args = call.arguments as? [String: Any]
        let deviceId = args?["deviceId"] as? String ?? "AURA-PRO-9842"
        let sdk = args?["sdkType"] as? String ?? "SDK_A"
        self.activeDeviceId = deviceId
        self.activeSdk = sdk
        self.isConnected = true
        result(["status": "connected", "deviceId": deviceId, "sdk": sdk])

      case "disconnectDevice":
        self.isConnected = false
        self.activeDeviceId = nil
        result(["status": "disconnected"])

      case "getConnectedDevice":
        if self.isConnected, let deviceId = self.activeDeviceId {
          result([
            "status": "connected",
            "deviceId": deviceId,
            "sdk": self.activeSdk,
            "telemetryIntervalMs": Int(self.telemetryIntervalMs * 1000)
          ])
        } else {
          result(["status": "disconnected"])
        }

      case "setTelemetryFrequency":
        let args = call.arguments as? [String: Any]
        let intervalMs = args?["intervalMs"] as? Int ?? 2000
        self.telemetryIntervalMs = max(0.5, Double(intervalMs) / 1000.0)
        self.restartTelemetryTimer()
        result(["telemetryIntervalMs": Int(self.telemetryIntervalMs * 1000)])

      case "runHardwareDiagnostics":
        let diag: [String: Any] = [
          "opticalPPG": "PASSED - 99.4% Signal Integrity",
          "temperatureSensor": "CALIBRATED - 0.02C Drift",
          "sixAxisIMU": "NORMAL - 100Hz ODR Active",
          "bleTransceiver": "OPTIMAL - CoreBluetooth TX Power 0dBm",
          "internalNAND": "HEALTHY - 32MB Free",
          "batteryHealth": "98% Retained Capacity"
        ]
        result(diag)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let telemetryChannel = FlutterEventChannel(
      name: telemetryChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    telemetryChannel.setStreamHandler(self)

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.telemetrySink = events
    restartTelemetryTimer()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.telemetrySink = nil
    self.telemetryTimer?.invalidate()
    self.telemetryTimer = nil
    return nil
  }

  private func restartTelemetryTimer() {
    self.telemetryTimer?.invalidate()
    self.telemetryTimer = Timer.scheduledTimer(withTimeInterval: telemetryIntervalMs, repeats: true) { [weak self] _ in
      guard let self = self, self.isConnected, let sink = self.telemetrySink else { return }
      let packet = self.generateTelemetryPacket()
      sink(packet)
    }
  }

  private func generateTelemetryPacket() -> [String: Any] {
    packetCounter += 1
    baseStepCount += Int64.random(in: 1...3)

    let heartRate = (activeSdk == "SDK_A") ? Int.random(in: 66...74) : Int.random(in: 68...76)
    let spo2 = Int.random(in: 98...99)
    let hrv = Int.random(in: 58...72)
    let tempDelta = Double(Int.random(in: -15...25)) / 100.0
    let stages = ["DEEP", "REM", "LIGHT", "AWAKE"]
    let sleepStage = stages[Int.random(in: 0..<stages.count)]

    var ecgWaveform: [Double] = []
    for i in 0..<16 {
      let phase = Double(i + Int(packetCounter % 8))
      let base = sin(phase * 0.7) * 0.4
      let spike = (i == 6) ? 1.2 : ((i == 7) ? -0.5 : 0.0)
      ecgWaveform.append(base + spike)
    }

    let rawString = "\(packetCounter)-\(activeDeviceId ?? "NONE")-\(heartRate)-\(spo2)-\(hrv)"
    let checksum = String(format: "%08X", rawString.hashValue & 0xFFFFFFFF)

    return [
      "packetId": packetCounter,
      "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
      "deviceId": activeDeviceId ?? "NONE",
      "sdk": activeSdk,
      "heartRate": heartRate,
      "spo2": spo2,
      "hrv": hrv,
      "skinTempDelta": tempDelta,
      "sleepStage": sleepStage,
      "stepCount": baseStepCount,
      "batteryLevel": 89,
      "signalQuality": 99,
      "checksum": checksum,
      "ecgSamples": ecgWaveform
    ]
  }
}
