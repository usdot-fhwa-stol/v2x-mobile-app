package com.neaera.iss_scms

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import com.iss_scms.dm.android.localdevicesecurityapi.LocalSigning
import com.iss_scms.dm.android.localdevicesecurityapi.TokenType
import com.iss_scms.dm.android.localdevicesecurityapi.ScmsEnvironment
import com.iss_scms.dm.android.localdevicesecurityapi.ValidateStatus
import com.iss_scms.dm.android.localdevicesecurityapi.SigningAPIState
import android.content.Context
import kotlinx.coroutines.*
import android.util.Log

/** IssScmsPlugin */
class IssScmsPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context : Context
  private lateinit var scope : CoroutineScope

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "iss_scms")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
    scope = CoroutineScope(Dispatchers.IO)
  }

  @kotlin.ExperimentalStdlibApi
  override fun onMethodCall(call: MethodCall, result: Result) {
    val args = call.arguments<Map<String, Any>>()
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }else if(call.method == "init"){
      LocalSigning.init(context, ScmsEnvironment.PREPRODUCTION)
      result.success(null)
    }
    else if(call.method == "validate"){
      val message = args?.get("message") as ByteArray
      val hex = message.joinToString(separator = "") { "%02X".format(it) }
      try{
        val (valid, _) = LocalSigning.validate(message, true)
        result.success(valid.name)
      } catch (e: IllegalArgumentException) {
        result.success(ValidateStatus.FAILURE.name)
      }
    }else if(call.method == "sign"){
      val state = LocalSigning.getState()
      if( state== SigningAPIState.READY){
        val psid = args?.get("psid") as Int
        val tbsOer = args?.get("tbsOer") as ByteArray
        val jIndex = args?.get("jIndex") as? Int
        val digestSigner = args?.get("digestSigner") as? Boolean

        val outputArray = LocalSigning.sign(psid, tbsOer)
        result.success(outputArray) 
      }else{
        result.success(null)
      }
      
    }else if(call.method == "getDeviceCerts"){
      val token = args?.get("token") as String
      val tokenType = TokenType.values()[args?.get("tokenType") as Int]
      val deviceId = args?.get("deviceId") as String
      scope.launch {
        try {
            LocalSigning.getDeviceCerts(token, TokenType.DM_DASHBOARD, deviceId)
            Log.d("IssScmsPlugin", "Success in Downloading Certificates")
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        } catch (e: Exception) {
          Log.d("IssScmsPlugin", "Failure in Downloading Certificates: ${e.message}")
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
      }
    }else if(call.method == "getState"){
      val state = LocalSigning.getState()
      result.success(state.name) // Returning names for Enums because order is not guaranteed.
    }else if(call.method == "topOffCerts"){
      val token = args?.get("token") as String
      val deviceId = args?.get("deviceId") as String
      val tokenType = TokenType.values()[args?.get("tokenType") as Int]
      scope.launch {
        try {
            LocalSigning.topOffCerts(token, tokenType, deviceId)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
      }
    }
    else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
