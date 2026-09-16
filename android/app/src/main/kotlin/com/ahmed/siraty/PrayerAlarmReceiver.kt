package com.ahmed.siraty

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.os.PowerManager
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class PrayerAlarmReceiver : BroadcastReceiver() {

    companion object {
        const val CHANNEL_REMINDERS = "siraty_prayer_reminders"
        const val CHANNEL_ADHAN = "siraty_adhan_v2"

        const val EXTRA_ALARM_ID = "alarmId"
        const val EXTRA_PRAYER_KEY = "prayerKey"
        const val EXTRA_EVENT_TYPE = "eventType" // "reminder" | "adhan"
        const val EXTRA_RECITER_RAW = "reciterRawResource"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"

        private var staticWakeLock: PowerManager.WakeLock? = null

        @Synchronized
        fun acquireWakeLock(context: Context) {
            try {
                if (staticWakeLock == null) {
                    val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
                    staticWakeLock = powerManager?.newWakeLock(
                        PowerManager.PARTIAL_WAKE_LOCK,
                        "siraty:PrayerAlarmServiceWakeLock"
                    )
                }
                if (staticWakeLock?.isHeld == false) {
                    // Keep CPU awake for up to 5 minutes so AdhanPlaybackService can run
                    staticWakeLock?.acquire(5 * 60 * 1000L)
                    Log.d("SiratyAlarm", "Static service WakeLock acquired")
                }
            } catch (e: Exception) {
                Log.w("SiratyAlarm", "Error acquiring static WakeLock: ${e.message}")
            }
        }

        @Synchronized
        fun releaseWakeLock() {
            try {
                if (staticWakeLock?.isHeld == true) {
                    staticWakeLock?.release()
                    Log.d("SiratyAlarm", "Static service WakeLock released")
                }
            } catch (e: Exception) {
                Log.w("SiratyAlarm", "Error releasing static WakeLock: ${e.message}")
            }
            staticWakeLock = null
        }

        fun createNotificationChannels(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val notificationManager = context.getSystemService(NotificationManager::class.java) ?: return

                // Clean up old legacy channels if present
                try {
                    notificationManager.deleteNotificationChannel("siraty_adhan")
                    notificationManager.deleteNotificationChannel("siraty_adhan_service")
                } catch (_: Exception) {}

                val remindersChannel = NotificationChannel(
                    CHANNEL_REMINDERS,
                    "تذكيرات مواعيد الصلاة",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "تنبيه هادئ قبل دخول وقت الصلاة بـ ١٠ دقائق"
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                }

                val adhanChannel = NotificationChannel(
                    CHANNEL_ADHAN,
                    "أذان ومواقيت الصلاة",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "إشعار موعد الأذان الرسمي"
                    // Audio played by AdhanPlaybackService with USAGE_ALARM
                    setSound(null, null)
                    lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
                    enableLights(true)
                    enableVibration(true)
                }

                notificationManager.createNotificationChannel(remindersChannel)
                notificationManager.createNotificationChannel(adhanChannel)
            }
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        // Keep CPU awake across the transition
        acquireWakeLock(context)
        onReceiveInternal(context, intent)
    }

    private fun onReceiveInternal(context: Context, intent: Intent) {
        val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, 0)
        val eventType = intent.getStringExtra(EXTRA_EVENT_TYPE) ?: "reminder"
        val reciterRaw = intent.getStringExtra(EXTRA_RECITER_RAW) ?: "adhan_makkah"
        val title = intent.getStringExtra(EXTRA_TITLE) ?: "الصلاة"
        val body = intent.getStringExtra(EXTRA_BODY) ?: ""

        Log.d("SiratyAlarm", "🔔 Alarm fired: id=$alarmId type=$eventType title=$title")

        createNotificationChannels(context)
        cleanupFiredAlarm(context, alarmId)

        // Deep link intent to open Prayer page only when user taps notification
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/prayer")
        }
        val pendingOpen = PendingIntent.getActivity(
            context,
            alarmId,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val channelId = if (eventType == "adhan") CHANNEL_ADHAN else CHANNEL_REMINDERS
        val subText = if (eventType == "adhan") "أذان الصلاة 🕌" else "تذكير بالصلاة ⏳"

        val customSmallView = RemoteViews(context.packageName, R.layout.notification_prayer_small).apply {
            setImageViewResource(R.id.notification_icon, R.mipmap.ic_launcher)
            setTextViewText(R.id.notification_badge, subText)
            setTextViewText(R.id.notification_title, title)
            setTextViewText(R.id.notification_body, body)
        }

        val customExpandedView = RemoteViews(context.packageName, R.layout.notification_prayer_expanded).apply {
            setImageViewResource(R.id.notification_expanded_icon, R.mipmap.ic_launcher)
            setTextViewText(R.id.notification_expanded_badge, subText)
            setTextViewText(R.id.notification_expanded_title, title)
            setTextViewText(R.id.notification_expanded_body, body)
            setViewVisibility(R.id.notification_btn_stop, View.GONE)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setCustomContentView(customSmallView)
            .setCustomBigContentView(customExpandedView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentTitle(title)
            .setContentText(body)
            .setSubText(subText)
            .setContentIntent(pendingOpen)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setColor(0xFF1E4B3D.toInt())
            .setAutoCancel(true)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(
                if (eventType == "adhan") NotificationCompat.PRIORITY_MAX
                else NotificationCompat.PRIORITY_HIGH
            )
            .build()

        try {
            val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.notify(alarmId, notification)
        } catch (e: Exception) {
            Log.e("SiratyAlarm", "Failed to post notification: ${e.message}", e)
        }

        // If adhan event, trigger audio playback service
        if (eventType == "adhan") {
            val serviceIntent = Intent(context, AdhanPlaybackService::class.java).apply {
                action = AdhanPlaybackService.ACTION_PLAY
                putExtra(AdhanPlaybackService.EXTRA_RAW_RESOURCE, reciterRaw)
                putExtra(AdhanPlaybackService.EXTRA_TITLE, title)
                putExtra(AdhanPlaybackService.EXTRA_NOTIFICATION_ID, alarmId)
            }
            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(serviceIntent)
                } else {
                    context.startService(serviceIntent)
                }
                Log.d("SiratyAlarm", "Started AdhanPlaybackService for alarmId=$alarmId")
            } catch (e: Exception) {
                Log.e("SiratyAlarm", "Failed to start AdhanPlaybackService: ${e.message}", e)
                releaseWakeLock()
            }
        } else {
            // Play specific prayer reminder voice ("اقتربت صلاة الـ...")
            try {
                val resId = context.resources.getIdentifier(reciterRaw, "raw", context.packageName)
                if (resId != 0) {
                    val afd = context.resources.openRawResourceFd(resId)
                    if (afd != null) {
                        val mp = MediaPlayer().apply {
                            setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                                    .build()
                            )
                            setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                        }
                        afd.close()
                        mp.setOnCompletionListener { player ->
                            try {
                                player.release()
                            } catch (_: Exception) {}
                            releaseWakeLock()
                        }
                        mp.setOnErrorListener { player, _, _ ->
                            try {
                                player.release()
                            } catch (_: Exception) {}
                            releaseWakeLock()
                            true
                        }
                        mp.prepare()
                        mp.start()
                        Log.d("SiratyAlarm", "Playing prayer reminder voice: $reciterRaw")
                    } else {
                        releaseWakeLock()
                    }
                } else {
                    releaseWakeLock()
                }
            } catch (e: Exception) {
                Log.w("SiratyAlarm", "Could not play reminder sound: ${e.message}")
                releaseWakeLock()
            }
        }

        // Update home screen prayer widget if active
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetComponent = ComponentName(context, PrayerWidgetProvider::class.java)
            val widgetIds = appWidgetManager.getAppWidgetIds(widgetComponent)
            if (widgetIds != null && widgetIds.isNotEmpty()) {
                val updateIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
                }
                context.sendBroadcast(updateIntent)
            }
        } catch (_: Exception) {
            // Non-critical
        }
    }

    private fun cleanupFiredAlarm(context: Context, firedAlarmId: Int) {
        try {
            val prefs = context.getSharedPreferences("siraty_prayer_alarms", Context.MODE_PRIVATE)
            val savedIds = prefs.getStringSet("scheduled_alarm_ids", emptySet())?.toMutableSet() ?: return
            val jsonStr = prefs.getString("scheduled_payloads_json", null) ?: return

            savedIds.remove(firedAlarmId.toString())

            val jsonArray = org.json.JSONArray(jsonStr)
            val remaining = org.json.JSONArray()
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                if (obj.getInt("alarmId") != firedAlarmId) {
                    remaining.put(obj)
                }
            }

            prefs.edit()
                .putStringSet("scheduled_alarm_ids", savedIds)
                .putString("scheduled_payloads_json", remaining.toString())
                .apply()

            Log.d("SiratyAlarm", "Cleaned up fired alarm id=$firedAlarmId, ${remaining.length()} remaining")
        } catch (e: Exception) {
            Log.w("SiratyAlarm", "Failed to cleanup alarm: ${e.message}")
        }
    }
}
