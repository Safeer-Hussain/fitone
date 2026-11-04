package com.example.fitone

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.zip.CRC32
import kotlin.random.Random

class MainActivity : FlutterActivity() {
    private val controlChannelName = "com.safeer.fitone/ring_control"
    private val telemetryChannelName = "com.safeer.fitone/ring_telemetry"

    private var activeSdk: String = "SDK_A"
    private var activeDeviceId: String? = "AURA-PRO-9842"
    private var isConnected: Boolean = true
    private var telemetryIntervalMs: Long = 2000L
    private var packetCounter: Long = 1000L
    private var baseStepCount: Long = 7840L

    private val handler = Handler(Looper.getMainLooper())
    private var telemetrySink: EventChannel.EventSink? = null

    private val telemetryRunnable = object : Runnable {
        override fun run() {
            if (isConnected && telemetrySink != null) {
                val packet = generateTelemetryPacket()
                telemetrySink?.success(packet)
            }
            handler.postDelayed(this, telemetryIntervalMs)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, controlChannelName)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "scanDevices" -> {
                        val devices = listOf(
                            mapOf(
                                "id" to "AURA-PRO-9842",
                                "name" to "AuraRing Pro v2",
                                "sdk" to "SDK_A",
                                "battery" to 88,
                                "firmware" to "v2.4.1",
                                "rssi" to -58,
                                "connected" to (activeDeviceId == "AURA-PRO-9842" && isConnected)
                            ),
                            mapOf(
                                "id" to "KTX-ULTRA-1049",
                                "name" to "KinetixRing Ultra",
                                "sdk" to "SDK_B",
                                "battery" to 94,
                                "firmware" to "v1.9.8",
                                "rssi" to -52,
                                "connected" to (activeDeviceId == "KTX-ULTRA-1049" && isConnected)
                            )
                        )
                        result.success(devices)
                    }
                    "connectDevice" -> {
                        val deviceId = call.argument<String>("deviceId") ?: "AURA-PRO-9842"
                        val sdk = call.argument<String>("sdkType") ?: "SDK_A"
                        activeDeviceId = deviceId
                        activeSdk = sdk
                        isConnected = true
                        result.success(mapOf("status" to "connected", "deviceId" to deviceId, "sdk" to sdk))
                    }
                    "disconnectDevice" -> {
                        isConnected = false
                        activeDeviceId = null
                        result.success(mapOf("status" to "disconnected"))
                    }
                    "getConnectedDevice" -> {
                        if (isConnected && activeDeviceId != null) {
                            result.success(
                                mapOf(
                                    "status" to "connected",
                                    "deviceId" to activeDeviceId,
                                    "sdk" to activeSdk,
                                    "telemetryIntervalMs" to telemetryIntervalMs
                                )
                            )
                        } else {
                            result.success(mapOf("status" to "disconnected"))
                        }
                    }
                    "setTelemetryFrequency" -> {
                        val interval = call.argument<Int>("intervalMs")?.toLong() ?: 2000L
                        telemetryIntervalMs = interval.coerceAtLeast(500L)
                        result.success(mapOf("telemetryIntervalMs" to telemetryIntervalMs))
                    }
                    "runHardwareDiagnostics" -> {
                        val diag = mapOf(
                            "opticalPPG" to "PASSED - 99.4% Signal Integrity",
                            "temperatureSensor" to "CALIBRATED - 0.02C Drift",
                            "sixAxisIMU" to "NORMAL - 100Hz ODR Active",
                            "bleTransceiver" to "OPTIMAL - TX Power 0dBm",
                            "internalNAND" to "HEALTHY - 32MB Free",
                            "batteryHealth" to "98% Retained Capacity"
                        )
                        result.success(diag)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, telemetryChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    telemetrySink = events
                    handler.removeCallbacks(telemetryRunnable)
                    handler.post(telemetryRunnable)
                }

                override fun onCancel(arguments: Any?) {
                    telemetrySink = null
                    handler.removeCallbacks(telemetryRunnable)
                }
            })
    }

    private fun generateTelemetryPacket(): Map<String, Any> {
        packetCounter++
        baseStepCount += Random.nextInt(1, 4)

        val heartRate = if (activeSdk == "SDK_A") {
            68 + Random.nextInt(-4, 6)
        } else {
            71 + Random.nextInt(-5, 5)
        }

        val spo2 = 98 + Random.nextInt(0, 2)
        val hrv = 62 + Random.nextInt(-6, 8)
        val tempDelta = (Random.nextInt(-15, 25) / 100.0)
        val sleepStages = listOf("DEEP", "REM", "LIGHT", "AWAKE")
        val currentSleepStage = sleepStages[Random.nextInt(sleepStages.size)]

        val ecgWaveform = List(16) { index ->
            val phase = (index + (packetCounter % 8)).toDouble()
            val base = Math.sin(phase * 0.7) * 0.4
            val spike = if (index == 6) 1.2 else if (index == 7) -0.5 else 0.0
            (base + spike)
        }

        val rawForChecksum = "$packetCounter-$activeDeviceId-$heartRate-$spo2-$hrv"
        val crc = CRC32()
        crc.update(rawForChecksum.toByteArray())
        val checksumHex = crc.value.toString(16).uppercase()

        return mapOf(
            "packetId" to packetCounter,
            "timestamp" to System.currentTimeMillis(),
            "deviceId" to (activeDeviceId ?: "NONE"),
            "sdk" to activeSdk,
            "heartRate" to heartRate,
            "spo2" to spo2,
            "hrv" to hrv,
            "skinTempDelta" to tempDelta,
            "sleepStage" to currentSleepStage,
            "stepCount" to baseStepCount,
            "batteryLevel" to 89,
            "signalQuality" to 99,
            "checksum" to checksumHex,
            "ecgSamples" to ecgWaveform
        )
    }

    override fun onDestroy() {
        handler.removeCallbacks(telemetryRunnable)
        super.onDestroy()
    }
}
