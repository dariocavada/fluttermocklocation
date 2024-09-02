package com.example.fluttermocklocation

import android.location.Location
import android.location.LocationManager
import android.os.SystemClock
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper

/** FluttermocklocationPlugin */
class FluttermocklocationPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null
    private lateinit var context: Context
    private val handler = Handler(Looper.getMainLooper())
    private var updateInterval: Long = 5000 // Default delay of 5 seconds
    private val mockLocationRunnable = object : Runnable {
        override fun run() {
            // Repeatedly update mock location
            updateMockLocation(context, lastLatitude, lastLongitude, lastAltitude)
            handler.postDelayed(this, updateInterval) // Use the update interval
        }
    }
    private var lastLatitude = 0.0
    private var lastLongitude = 0.0
    private var lastAltitude = 0.0

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fluttermocklocation")
        channel.setMethodCallHandler(this)
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "fluttermocklocation_updates")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "updateMockLocation") {
            lastLatitude = call.argument<Double>("latitude") ?: 0.0
            lastLongitude = call.argument<Double>("longitude") ?: 0.0
            lastAltitude = call.argument<Double>("altitude") ?: 0.0
            updateInterval = (call.argument<Number>("delay")?.toLong()) ?: 5000L  // Default to 5000 ms if not provided
            updateMockLocation(context, lastLatitude, lastLongitude, lastAltitude)
            handler.post(mockLocationRunnable) // Start periodic updates
            result.success(null)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        handler.removeCallbacks(mockLocationRunnable) // Stop periodic updates
    }

    private fun updateMockLocation(context: Context, latitude: Double, longitude: Double, altitude: Double) {
        val locationManager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        try {
            locationManager.addTestProvider(
                LocationManager.GPS_PROVIDER,
                false, false, false, false, true,
                true, true, 1, 2
            )
            locationManager.setTestProviderEnabled(LocationManager.GPS_PROVIDER, true)

            val mockLocation = Location(LocationManager.GPS_PROVIDER).apply {
                setLatitude(latitude)
                setLongitude(longitude)
                this.altitude = altitude
                time = System.currentTimeMillis()
                elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
                accuracy = 5f
            }

            locationManager.setTestProviderLocation(LocationManager.GPS_PROVIDER, mockLocation)

            // Send location update to Flutter
            eventSink?.success(mapOf(
                "latitude" to latitude,
                "longitude" to longitude,
                "altitude" to altitude
            ))
        } catch (e: SecurityException) {
            // Handle exception if permissions are not adequate
        } catch (e: IllegalArgumentException) {
            // Handle other types of errors, like providing an invalid provider
        }
    }
}