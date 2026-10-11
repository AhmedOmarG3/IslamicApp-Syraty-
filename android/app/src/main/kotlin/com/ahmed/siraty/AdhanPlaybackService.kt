package com.ahmed.siraty

import android.app.Notification
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class AdhanPlaybackService : Service() {

    companion object {
        const val ACTION_PLAY = "com.ahmed.siraty.action.PLAY_ADHAN"
        const val ACTION_STOP = "com.ahmed.siraty.action.STOP_ADHAN"
        const val EXTRA_RAW_RESOURCE = "extra_raw_resource"
        const val EXTRA_TITLE = "extra_title"
        const val EXTRA_NOTIFICATION_ID = "extra_notification_id"
        const val FALLBACK_NOTIFICATION_ID = 9991
    }

    private var mediaPlayer: MediaPlayer? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            stopSelf()
            return START_NOT_STICKY
        }

        when (intent.action) {
            ACTION_STOP -> {
                Log.d("AdhanService", "Stop action received")
                stopPlayback()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    stopForeground(STOP_FOREGROUND_REMOVE)
                } else {
                    @Suppress("DEPRECATION")
                    stopForeground(true)
                }
                stopSelf()
            }
            ACTION_PLAY -> {
                val rawResName = intent.getStringExtra(EXTRA_RAW_RESOURCE) ?: "adhan_makkah"
                val title = intent.getStringExtra(EXTRA_TITLE) ?: "حان الآن موعد الأذان"
                val notifId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, FALLBACK_NOTIFICATION_ID)

                acquireWakeLock()

                // Ensure the channel exists
                PrayerAlarmReceiver.createNotificationChannels(this)

                val notification = buildForegroundNotification(title, notifId)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(
                        notifId,
                        notification,
                        android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK
                    )
                } else {
                    startForeground(notifId, notification)
                }
                playAdhan(rawResName)
            }
            else -> stopSelf()
        }

        return START_NOT_STICKY
    }

    private fun acquireWakeLock() {
        try {
            if (wakeLock == null) {
                val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                wakeLock = powerManager?.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    "siraty:AdhanPlaybackWakeLock"
                )
            }
            if (wakeLock?.isHeld == false) {
                wakeLock?.acquire(10 * 60 * 1000L) // 10 minutes max
                Log.d("AdhanService", "Acquired Adhan playback WakeLock")
            }
        } catch (e: Exception) {
            Log.w("AdhanService", "Failed to acquire WakeLock: ${e.message}")
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
                Log.d("AdhanService", "Released Adhan playback WakeLock")
            }
        } catch (e: Exception) {
            Log.w("AdhanService", "Failed to release WakeLock: ${e.message}")
        }
        wakeLock = null
    }

    private fun playAdhan(rawResName: String) {
        stopPlaybackOnly()

        val resId = resources.getIdentifier(rawResName, "raw", packageName).let {
            if (it == 0) resources.getIdentifier("adhan_makkah", "raw", packageName) else it
        }

        if (resId == 0) {
            Log.e("AdhanService", "Audio resource $rawResName not found!")
            stopPlayback()
            stopSelf()
            return
        }

        requestAudioFocus()

        // Ensure alarm stream volume is audible even if muted
        try {
            val am = audioManager ?: (getSystemService(Context.AUDIO_SERVICE) as? AudioManager)
            val currentVol = am?.getStreamVolume(AudioManager.STREAM_ALARM) ?: 0
            val maxVol = am?.getStreamMaxVolume(AudioManager.STREAM_ALARM) ?: 1
            if (currentVol == 0) {
                am?.setStreamVolume(AudioManager.STREAM_ALARM, (maxVol * 0.75).toInt(), 0)
                Log.d("AdhanService", "Alarm volume was 0, boosted to 75%")
            }
        } catch (e: Exception) {
            Log.w("AdhanService", "Could not check alarm volume: ${e.message}")
        }

        try {
            val afd = resources.openRawResourceFd(resId) ?: run {
                Log.e("AdhanService", "Could not open RawResourceFd for $resId")
                stopPlayback()
                stopSelf()
                return
            }

            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .build()
                )
                setWakeMode(applicationContext, PowerManager.PARTIAL_WAKE_LOCK)
                setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                afd.close()

                setOnCompletionListener {
                    Log.d("AdhanService", "Adhan playback completed naturally")
                    stopPlayback()
                    stopSelf()
                }

                setOnErrorListener { _, what, extra ->
                    Log.e("AdhanService", "MediaPlayer error: what=$what extra=$extra")
                    stopPlayback()
                    stopSelf()
                    true
                }

                prepare()
                start()
            }
            Log.d("AdhanService", "Adhan playback started successfully with raw/$rawResName")
        } catch (e: Exception) {
            Log.e("AdhanService", "Failed to play adhan: ${e.message}", e)
            stopPlayback()
            stopSelf()
        }
    }

    private fun stopPlaybackOnly() {
        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
            }
        } catch (e: Exception) {
            Log.w("AdhanService", "Error stopping player: ${e.message}")
        }
        mediaPlayer = null
    }

    private fun stopPlayback() {
        stopPlaybackOnly()
        abandonAudioFocus()
        releaseWakeLock()
        PrayerAlarmReceiver.releaseWakeLock()
    }

    private fun requestAudioFocus() {
        val am = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val attr = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(attr)
                .build().also {
                    am.requestAudioFocus(it)
                }
        } else {
            @Suppress("DEPRECATION")
            am.requestAudioFocus(null, AudioManager.STREAM_ALARM, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
        }
    }

    private fun abandonAudioFocus() {
        val am = audioManager ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { am.abandonAudioFocusRequest(it) }
        } else {
            @Suppress("DEPRECATION")
            am.abandonAudioFocus(null)
        }
    }

    private fun buildForegroundNotification(title: String, notifId: Int): Notification {
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/prayer")
        }
        val openPendingIntent = PendingIntent.getActivity(
            this,
            notifId,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val stopIntent = Intent(this, PrayerAlarmReceiver::class.java).apply {
            action = PrayerAlarmReceiver.ACTION_STOP_ADHAN
            putExtra(PrayerAlarmReceiver.EXTRA_ALARM_ID, notifId)
        }
        val stopPendingIntent = PendingIntent.getBroadcast(
            this,
            notifId + 10_000,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val customSmall = RemoteViews(packageName, R.layout.notification_prayer_small).apply {
            setTextViewText(R.id.notification_title, title)
            setTextViewText(R.id.notification_body, "حي على الصلاة، حي على الفلاح")
        }

        val customExpanded = RemoteViews(packageName, R.layout.notification_prayer_expanded).apply {
            setTextViewText(R.id.notification_expanded_title, title)
            setTextViewText(R.id.notification_expanded_body, "حي على الصلاة، حي على الفلاح")
        }

        val builder = NotificationCompat.Builder(this, PrayerAlarmReceiver.CHANNEL_ADHAN)
            .setSmallIcon(R.drawable.ic_siraty_notification)
            .setColor(Color.parseColor("#1B4D3E"))
            .setCustomContentView(customSmall)
            .setCustomBigContentView(customExpanded)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentTitle(title)
            .setContentText("حي على الصلاة، حي على الفلاح")
            .setSubText("صوت الأذان 🔊")
            .setContentIntent(openPendingIntent)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .addAction(android.R.drawable.ic_media_pause, "إيقاف الأذان", stopPendingIntent)
            .setDeleteIntent(stopPendingIntent)
            .setOngoing(false)

        return builder.build()
    }

    override fun onDestroy() {
        stopPlayback()
        super.onDestroy()
    }
}
