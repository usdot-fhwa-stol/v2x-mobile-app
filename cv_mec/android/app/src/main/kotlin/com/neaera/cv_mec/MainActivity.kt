package com.neaera.cv_mec

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.util.Base64
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.app.RemoteInput
import androidx.core.content.ContextCompat
import androidx.core.graphics.drawable.IconCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import com.oguzhnatly.flutter_android_auto.FAAConstants
import java.util.Calendar


private const val channel_id = "cv_mec_alerts";
private const val channel_name = "cv_mec_alerts";
private const val channel_description = "CV Mec Traveler Information Message Alerts";

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        // Create the NotificationChannel
        val importance = NotificationManager.IMPORTANCE_HIGH
        val channel = NotificationChannel(channel_id, channel_name, importance).apply {
            description = channel_description
        }

        // Register the channel with the system.
        val notificationManager: NotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
    }

    private fun base64ToBitmap(base64String: String?): Bitmap? {
        if (base64String == null) {
            return null
        }
        val decodedString = Base64.decode(base64String, Base64.DEFAULT)
        return BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
    }

    private fun notify(notificationId: Int, description: String, image: Bitmap?) {
        val context: Context = this
        val imageBitmap = image ?: BitmapFactory.decodeResource(resources, R.drawable.baseline_change_history_24)

        val notification = NotificationCompat.Builder(context, channel_id)
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("CV MEC Alert")
            .setContentText(description)
            .setLargeIcon(imageBitmap)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        val notificationManagerCompat = NotificationManagerCompat.from(context)
        if (ActivityCompat.checkSelfPermission(
                this,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        notificationManagerCompat.notify(notificationId, notification)
    }

    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        // Use engine from cache if it has been started by Android Auto.
        return FlutterEngineCache.getInstance().get(FAAConstants.flutterEngineId);
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Cache the engine to make it usable by Android Auto.
        FlutterEngineCache.getInstance().put(FAAConstants.flutterEngineId, flutterEngine)
        super.configureFlutterEngine(flutterEngine)
    }
}
