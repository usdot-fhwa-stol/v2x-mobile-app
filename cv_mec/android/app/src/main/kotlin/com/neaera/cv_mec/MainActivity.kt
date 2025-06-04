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
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar


private const val ACTION_REPLY = "com.example.REPLY"
private const val ACTION_MARK_AS_READ = "com.example.MARK_AS_READ"

private const val EXTRA_CONVERSATION_ID_KEY = "conversation_id"
private const val REMOTE_INPUT_RESULT_KEY = "reply_input"

private const val channel_id = "cv_mec_alerts";
private const val channel_name = "cv_mec_alerts";
private const val channel_description = "CV Mec Traveler Information Message Alerts";

private const val COMMUNICATION_CHANNEL_NAME = "com.neaera.cv_mec/vehicle-notification"
private const val COMMAND_NOTIFY = "notify"

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMUNICATION_CHANNEL_NAME).setMethodCallHandler {
                call, result ->
            if (call.method == COMMAND_NOTIFY) {
                val id = call.argument<Int>("id")!!
                val description = call.argument<String>("description")!!
                val image = call.argument<String>("image_b64")
                notify(id, description, base64ToBitmap(image));
                result.success(id);
            }
            else {
                result.notImplemented()
            }
        }
    }

    // ######################### The notification code below is taken from this guide: https://developer.android.com/training/cars/messaging
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

    /**
     * Creates a [RemoteInput] that lets remote apps provide a response string
     * to the underlying [Intent] within a [PendingIntent].
     */
    private fun createReplyRemoteInput(context: Context): RemoteInput {
        // RemoteInput.Builder accepts a single parameter: the key to use to store
        // the response in.
        return RemoteInput.Builder(REMOTE_INPUT_RESULT_KEY).build()
        // Note that the RemoteInput has no knowledge of the conversation. This is
        // because the data for the RemoteInput is bound to the reply Intent using
        // static methods in the RemoteInput class.
    }

    /** Creates an [Intent] that handles replying to the given conversation. */
    private fun createReplyIntent(
        context: Context, notificationId: Int): Intent {
        // Creates the intent backed by the MessagingService.
        val intent = Intent(context, MainActivity::class.java)

        // Lets the MessagingService know this is a reply request.
        intent.action = ACTION_REPLY

        // Provides the ID of the conversation that the reply applies to.
        intent.putExtra(EXTRA_CONVERSATION_ID_KEY, notificationId)

        return intent
    }

    /** Creates an [Intent] that handles marking the conversation as read. */
    private fun createMarkAsReadIntent(
        context: Context, notificationId: Int): Intent {
        val intent = Intent(context, MainActivity::class.java)
        intent.action = ACTION_MARK_AS_READ
        intent.putExtra(EXTRA_CONVERSATION_ID_KEY, notificationId)
        return intent
    }

    private fun createMarkAsReadAction(
        context: Context, notificationId: Int): NotificationCompat.Action {
        val markAsReadIntent = createMarkAsReadIntent(context, notificationId)
        val markAsReadPendingIntent = PendingIntent.getService(
            context,
            12345, // TODO: Is this right?
            markAsReadIntent,
            PendingIntent.FLAG_UPDATE_CURRENT  or PendingIntent.FLAG_IMMUTABLE)
        val markAsReadAction = NotificationCompat.Action.Builder(
            R.drawable.baseline_close_24, "Close", markAsReadPendingIntent)
            .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_MARK_AS_READ)
            .setShowsUserInterface(false)
            .build()
        return markAsReadAction
    }

    private fun createReplyAction(
        context: Context, notificationId: Int): NotificationCompat.Action {
        val replyIntent: Intent = createReplyIntent(context, notificationId)

        val replyPendingIntent = PendingIntent.getService(
            context,
            12345, // TODO: Is this right?
            replyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)

        val replyAction = NotificationCompat.Action.Builder(R.drawable.baseline_feedback_24, "Submit Feedback", replyPendingIntent)
            // Provides context to what firing the Action does.
            .setSemanticAction(NotificationCompat.Action.SEMANTIC_ACTION_REPLY)

            // The action doesn't show any UI, as required by Android Auto.
            .setShowsUserInterface(false)

            // Don't forget the reply RemoteInput. Android Auto will use this to
            // make a system call that will add the response string into
            // the reply intent so it can be extracted by the messaging app.
            .addRemoteInput(createReplyRemoteInput(context))
            .build()

        return replyAction
    }

    private fun createMessagingStyle(
        context: Context, notificationId: Int, description: String): NotificationCompat.MessagingStyle {
        // Method defined by the messaging app.
        val appDeviceUser = "CV_MEC"
        val blankBitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888) // 1x1 transparent pixel

        val devicePerson = Person.Builder()
            // The display name (also the name that's read aloud in Android auto).
            .setName(appDeviceUser)

            // The icon to show in the notification shade in the system UI (outside
            // of Android Auto).
            .setIcon(IconCompat.createWithResource(context, R.drawable.baseline_account_circle_24))

            // A unique key in case there are multiple people in this conversation with
            // the same name.
            .setKey(appDeviceUser)
            .build()

        val messagingStyle = NotificationCompat.MessagingStyle(devicePerson)

        // Sets the conversation title. If the app's target version is lower
        // than P, this will automatically mark the conversation as a group (to
        // maintain backward compatibility). Use `setGroupConversation` after
        // setting the conversation title to explicitly override this behavior. See
        // the documentation for more information.
        messagingStyle.setConversationTitle("Alerts")

        // Group conversation means there is more than 1 recipient, so set it as such.
        messagingStyle.setGroupConversation(false)

        val senderPerson = Person.Builder()
            .setName(appDeviceUser)
            .setIcon(IconCompat.createWithBitmap(blankBitmap))
            .setKey(appDeviceUser)
            .build()

        // Adds the message. More complex messages, like images,
        // can be created and added by instantiating the MessagingStyle.Message
        // class directly. See documentation for details.
        messagingStyle.addMessage(
            description, Calendar.getInstance().time.toInstant().toEpochMilli(), senderPerson)

        return messagingStyle
    }

    private fun drawableToBitmap(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }

    private fun base64ToBitmap(base64String: String?): Bitmap? {
        if (base64String == null) {
            return null;
        }
        // Decode the Base64 string into a byte array
        val decodedString: ByteArray = Base64.decode(base64String, Base64.DEFAULT)
        // Convert byte array into Bitmap
        return BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
    }

    private fun notify(notificationId: Int, description: String, image: Bitmap?) {
        val context: Context = this;
        // Creates the actions and MessagingStyle.
        val replyAction = createReplyAction(context, notificationId)
        val markAsReadAction = createMarkAsReadAction(context, notificationId)
        val messagingStyle = createMessagingStyle(context, notificationId, description)

        val imageBitmap: Bitmap = image ?: drawableToBitmap(ContextCompat.getDrawable(context, R.drawable.baseline_change_history_24)!!)

        // Creates the notification.
        val notification = NotificationCompat.Builder(context, channel_id)
            // A required field for the Android UI.
            .setSmallIcon(R.drawable.ic_notification)
            .setCategory(Notification.CATEGORY_MESSAGE)
            // Shows in Android Auto as the conversation image.
            .setLargeIcon(imageBitmap)

            // Adds MessagingStyle.
            .setStyle(messagingStyle)
            .setPriority(NotificationManager.IMPORTANCE_HIGH)

            // Adds reply action.
            .addInvisibleAction(replyAction)

            // Makes the mark-as-read action invisible, so it doesn't appear
            // in the Android UI but the app satisfies Android Auto's
            // mark-as-read Action requirement. Both required actions can be made
            // visible or invisible; it is a stylistic choice.
            .addInvisibleAction(markAsReadAction)

            .build()

        // Posts the notification for the user to see.
        val notificationManagerCompat = NotificationManagerCompat.from(context)
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        notificationManagerCompat.notify(notificationId, notification)
    }
}
