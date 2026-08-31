package com.neaera.imu_plugin_native

import android.app.Activity
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ImuPluginNativePlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware,
    SensorEventListener {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel

    private var activity: Activity? = null
    private var applicationContext: Context? = null
    private var sensorManager: SensorManager? = null

    private var eventSink: EventChannel.EventSink? = null
    private var isStreaming: Boolean = false
    private var samplingPeriodUs: Int = 20_000

    private val trackedSensorTypes = listOf(
        Sensor.TYPE_ROTATION_VECTOR,
        Sensor.TYPE_GAME_ROTATION_VECTOR,
        Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR,
        Sensor.TYPE_GRAVITY,
        Sensor.TYPE_LINEAR_ACCELERATION,
        Sensor.TYPE_GYROSCOPE,
    )

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "imu_plugin_native/methods")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "imu_plugin_native/events")
        eventChannel.setStreamHandler(this)

        initializeSensorManager()
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopSensorStreaming()
        eventChannel.setStreamHandler(null)
        methodChannel.setMethodCallHandler(null)
        eventSink = null
        sensorManager = null
        applicationContext = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        initializeSensorManager()
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                result.success(initializeSensorManager())
            }
            "startStreaming" -> {
                isStreaming = true
                result.success(startStreamingRequested())
            }
            "stopStreaming" -> {
                isStreaming = false
                stopSensorStreaming()
                result.success(true)
            }
            "setSamplingPeriodUs" -> {
                val updatedPeriod = (call.argument<Number>("samplingPeriodUs") ?: samplingPeriodUs).toInt()
                if (updatedPeriod <= 0) {
                    result.success(false)
                    return
                }
                samplingPeriodUs = updatedPeriod
                if (isStreaming && eventSink != null) {
                    restartSensorStreaming()
                }
                result.success(true)
            }
            "getAvailabilityMap" -> {
                result.success(buildAvailabilityMap())
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        eventSink = events
        if (isStreaming) {
            startSensorStreaming()
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        stopSensorStreaming()
    }

    override fun onSensorChanged(event: SensorEvent) {
        val sink = eventSink ?: return
        val payload = hashMapOf<String, Any>(
            "sensorType" to event.sensor.type,
            "sensorName" to sensorTypeName(event.sensor.type),
            "accuracy" to event.accuracy,
            "timestampNanos" to event.timestamp,
            "values" to event.values.map { it.toDouble() },
        )

        if (isRotationVectorType(event.sensor.type)) {
            val orientationDegrees = computeOrientationDegrees(event.values)
            if (orientationDegrees != null) {
                payload["yawDeg"] = orientationDegrees[0]
                payload["pitchDeg"] = orientationDegrees[1]
                payload["rollDeg"] = orientationDegrees[2]
            }
        }
        sink.success(payload)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // Accuracy is reported with each SensorEvent; no-op to keep stream payload compact.
    }

    private fun initializeSensorManager(): Boolean {
        val context = activity ?: applicationContext ?: return false
        sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return true
    }

    private fun startSensorStreaming(): Boolean {
        val manager = sensorManager ?: return false
        if (eventSink == null) {
            return false
        }
        var registeredAny = false
        for (sensorType in trackedSensorTypes) {
            val sensor = manager.getDefaultSensor(sensorType) ?: continue
            registeredAny = manager.registerListener(this, sensor, samplingPeriodUs) || registeredAny
        }
        return registeredAny
    }

    private fun startStreamingRequested(): Boolean {
        val manager = sensorManager ?: return false
        val hasAnyRequestedSensor = trackedSensorTypes.any { sensorType ->
            manager.getDefaultSensor(sensorType) != null
        }
        if (!hasAnyRequestedSensor) {
            return false
        }
        if (eventSink != null) {
            return startSensorStreaming()
        }
        return true
    }

    private fun stopSensorStreaming() {
        val manager = sensorManager ?: return
        manager.unregisterListener(this)
    }

    private fun restartSensorStreaming() {
        stopSensorStreaming()
        startSensorStreaming()
    }

    private fun buildAvailabilityMap(): Map<String, Boolean> {
        val manager = sensorManager ?: return trackedSensorTypes.associate { sensorTypeName(it) to false }
        return trackedSensorTypes.associate { sensorType ->
            sensorTypeName(sensorType) to (manager.getDefaultSensor(sensorType) != null)
        }
    }

    private fun sensorTypeName(sensorType: Int): String {
        return when (sensorType) {
            Sensor.TYPE_ROTATION_VECTOR -> "TYPE_ROTATION_VECTOR"
            Sensor.TYPE_GAME_ROTATION_VECTOR -> "TYPE_GAME_ROTATION_VECTOR"
            Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR -> "TYPE_GEOMAGNETIC_ROTATION_VECTOR"
            Sensor.TYPE_GRAVITY -> "TYPE_GRAVITY"
            Sensor.TYPE_LINEAR_ACCELERATION -> "TYPE_LINEAR_ACCELERATION"
            Sensor.TYPE_GYROSCOPE -> "TYPE_GYROSCOPE"
            else -> sensorType.toString()
        }
    }

    private fun isRotationVectorType(sensorType: Int): Boolean {
        return sensorType == Sensor.TYPE_ROTATION_VECTOR ||
            sensorType == Sensor.TYPE_GAME_ROTATION_VECTOR ||
            sensorType == Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR
    }

    private fun computeOrientationDegrees(rotationVectorValues: FloatArray): FloatArray? {
        return try {
            val rotationMatrix = FloatArray(9)
            SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVectorValues)
            val orientationRadians = FloatArray(3)
            SensorManager.getOrientation(rotationMatrix, orientationRadians)
            floatArrayOf(
                Math.toDegrees(orientationRadians[0].toDouble()).toFloat(),
                Math.toDegrees(orientationRadians[1].toDouble()).toFloat(),
                Math.toDegrees(orientationRadians[2].toDouble()).toFloat(),
            )
        } catch (_: IllegalArgumentException) {
            null
        }
    }
}
