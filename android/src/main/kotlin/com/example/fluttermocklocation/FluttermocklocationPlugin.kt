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

/** FluttermocklocationPlugin */
class FluttermocklocationPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context 

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fluttermocklocation")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "updateMockLocation") {
        val latitude = call.argument<Double>("latitude") ?: 0.0
        val longitude = call.argument<Double>("longitude") ?: 0.0
        updateMockLocation(context, latitude, longitude, result)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun updateMockLocation(context: Context, latitude: Double, longitude: Double, result: Result) {
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
            altitude = 0.0
            time = System.currentTimeMillis()
            elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
            accuracy = 5f
        }

        locationManager.setTestProviderLocation(LocationManager.GPS_PROVIDER, mockLocation)
        result.success(null) // Operazione completata con successo
    } catch (e: SecurityException) {
        // Gestisce l'eccezione nel caso in cui non ci siano i permessi adeguati
        result.error("SECURITY_EXCEPTION", "Errore nel mock della posizione: ${e.message}", null)
    } catch (e: IllegalArgumentException) {
        // Gestisce altri tipi di errori, come la fornitura di un provider non valido
        result.error("ILLEGAL_ARGUMENT_EXCEPTION", "Errore nel mock della posizione: ${e.message}", null)
    }
  }
}
