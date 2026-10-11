package com.ahmed.siraty

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.os.Build
import android.os.SystemClock
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar

object OngoingPrayerNotification {

    const val CHANNEL_ID = "siraty_prayer_ongoing"
    const val NOTIFICATION_ID = 8888
    const val KEY_ONGOING_ENABLED = "prayer_ongoing_notification_enabled"

    private fun toArabicDigits(input: String): String {
        val english = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
        val arabic = charArrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
        var result = input
        for (i in english.indices) {
            result = result.replace(english[i], arabic[i])
        }
        return result
    }

    private fun toEnglishDigits(input: String): String {
        val english = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
        val arabic = charArrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
        var result = input
        for (i in arabic.indices) {
            result = result.replace(arabic[i], english[i])
        }
        return result
    }

    private fun getSafeLong(prefs: SharedPreferences, key: String): Long {
        return try {
            val all = prefs.all
            when (val v = all[key] ?: all["${key}_str"]) {
                is Long -> v
                is Int -> v.toLong()
                is Number -> v.toLong()
                is String -> v.toLongOrNull() ?: 0L
                else -> 0L
            }
        } catch (_: Exception) {
            0L
        }
    }


    /**
     * Fallback parser if epochs were not yet saved: converts Arabic or English "HH:mm" time to today's epoch.
     */
    private fun parseTimeToEpoch(timeStr: String, prayerType: String): Long {
        return try {
            val clean = toEnglishDigits(timeStr).replace("م", "").replace("ص", "").trim()
            val parts = clean.split(":")
            if (parts.size >= 2) {
                var hour = parts[0].trim().toInt()
                val min = parts[1].trim().toInt()
                when (prayerType) {
                    "fajr", "shuruq" -> {
                        if (hour == 12) hour = 0
                    }
                    "dhuhr" -> {
                        if (hour in 1..10) hour += 12
                    }
                    "asr", "maghrib", "isha" -> {
                        if (hour < 12) hour += 12
                    }
                }
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, hour)
                    set(Calendar.MINUTE, min)
                    set(Calendar.SECOND, 0)
                    set(Calendar.MILLISECOND, 0)
                }
                cal.timeInMillis
            } else 0L
        } catch (_: Exception) {
            0L
        }
    }

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = context.getSystemService(NotificationManager::class.java) ?: return
            val channel = NotificationChannel(
                CHANNEL_ID,
                "مواقيت الصلاة المستمرة",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "عرض موعد الصلاة القادمة والمواقيت باستمرار"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
                setSound(null, null)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun cancel(context: Context) {
        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            nm?.cancel(NOTIFICATION_ID)
        } catch (e: Exception) {
            Log.w("OngoingPrayer", "Failed to cancel notification: ${e.message}")
        }
    }

    fun update(context: Context) {
        // Read from HomeWidget SharedPreferences where PrayerWidgetService saves data
        val widgetPrefs = try {
            HomeWidgetPlugin.getData(context)
        } catch (_: Exception) {
            context.getSharedPreferences("${context.packageName}_preferences", Context.MODE_PRIVATE)
        }

        // Check if user enabled ongoing notification from Flutter settings
        val flutterPrefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val isEnabled = flutterPrefs.getBoolean("flutter.$KEY_ONGOING_ENABLED", true) &&
                flutterPrefs.getBoolean(KEY_ONGOING_ENABLED, true)

        if (!isEnabled) {
            cancel(context)
            return
        }

        createNotificationChannel(context)

        val city = widgetPrefs.getString("prayer_city", null)
            ?: flutterPrefs.getString("flutter.prayer_city", "القاهرة")
            ?: "القاهرة"

        val fajr = widgetPrefs.getString("prayer_fajr_time", "٠٤:٣٥") ?: "٠٤:٣٥"
        val shuruq = widgetPrefs.getString("prayer_shuruq_time", "٠٦:٠١") ?: "٠٦:٠١"
        val dhuhr = widgetPrefs.getString("prayer_dhuhr_time", "١١:٥٨") ?: "١١:٥٨"
        val asr = widgetPrefs.getString("prayer_asr_time", "٠٣:٢٦") ?: "٠٣:٢٦"
        val maghrib = widgetPrefs.getString("prayer_maghrib_time", "٠٦:٠٤") ?: "٠٦:٠٤"
        val isha = widgetPrefs.getString("prayer_isha_time", "٠٧:٢٢") ?: "٠٧:٢٢"

        var fajrEpoch = getSafeLong(widgetPrefs, "prayer_fajr_epoch")
        var dhuhrEpoch = getSafeLong(widgetPrefs, "prayer_dhuhr_epoch")
        var asrEpoch = getSafeLong(widgetPrefs, "prayer_asr_epoch")
        var maghribEpoch = getSafeLong(widgetPrefs, "prayer_maghrib_epoch")
        var ishaEpoch = getSafeLong(widgetPrefs, "prayer_isha_epoch")

        // If epochs were not stored, fall back to parsing the strings
        if (fajrEpoch == 0L) fajrEpoch = parseTimeToEpoch(fajr, "fajr")
        if (dhuhrEpoch == 0L) dhuhrEpoch = parseTimeToEpoch(dhuhr, "dhuhr")
        if (asrEpoch == 0L) asrEpoch = parseTimeToEpoch(asr, "asr")
        if (maghribEpoch == 0L) maghribEpoch = parseTimeToEpoch(maghrib, "maghrib")
        if (ishaEpoch == 0L) ishaEpoch = parseTimeToEpoch(isha, "isha")

        var resolvedNextName: String
        var resolvedNextTime: String
        var resolvedNextKey: String
        var targetEpoch: Long

        val now = System.currentTimeMillis()

        // Check if Flutter already saved the next prayer calculation
        val savedNextEpoch = getSafeLong(widgetPrefs, "prayer_next_epoch")
        val savedNextName = widgetPrefs.getString("prayer_next_name", null)
        val savedNextTime = widgetPrefs.getString("prayer_next_time", null)
        val savedNextKey = widgetPrefs.getString("prayer_next_key", null)

        if (savedNextEpoch > now && !savedNextName.isNullOrEmpty() && !savedNextTime.isNullOrEmpty()) {
            resolvedNextName = savedNextName
            resolvedNextTime = savedNextTime
            resolvedNextKey = savedNextKey ?: ""
            targetEpoch = savedNextEpoch
        } else {
            // Recalculate accurately based on current epoch
            when {
                now < fajrEpoch -> {
                    resolvedNextName = "الفجر"
                    resolvedNextTime = fajr
                    resolvedNextKey = "fajr"
                    targetEpoch = fajrEpoch
                }
                now < dhuhrEpoch -> {
                    resolvedNextName = "الظهر"
                    resolvedNextTime = dhuhr
                    resolvedNextKey = "dhuhr"
                    targetEpoch = dhuhrEpoch
                }
                now < asrEpoch -> {
                    resolvedNextName = "العصر"
                    resolvedNextTime = asr
                    resolvedNextKey = "asr"
                    targetEpoch = asrEpoch
                }
                now < maghribEpoch -> {
                    resolvedNextName = "المغرب"
                    resolvedNextTime = maghrib
                    resolvedNextKey = "maghrib"
                    targetEpoch = maghribEpoch
                }
                now < ishaEpoch -> {
                    resolvedNextName = "العشاء"
                    resolvedNextTime = isha
                    resolvedNextKey = "isha"
                    targetEpoch = ishaEpoch
                }
                else -> {
                    // Past Isha -> next prayer is tomorrow's Fajr
                    resolvedNextName = "الفجر"
                    resolvedNextTime = fajr
                    resolvedNextKey = "fajr"
                    targetEpoch = if (fajrEpoch > 0L) fajrEpoch + (24 * 60 * 60 * 1000L) else (now + 6 * 3600 * 1000L)
                }
            }
        }

        val remainingMillis = (targetEpoch - now).coerceAtLeast(1000L)

        // Intents
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/prayer")
        }
        val pendingOpen = PendingIntent.getActivity(
            context,
            NOTIFICATION_ID,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val refreshIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("route", "/prayer-location")
        }
        val pendingRefresh = PendingIntent.getActivity(
            context,
            NOTIFICATION_ID + 1,
            refreshIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        // Collapsed View
        val smallView = RemoteViews(context.packageName, R.layout.notification_prayer_ongoing_small).apply {
            setTextViewText(R.id.ongoing_city, city)
            setTextViewText(R.id.ongoing_next_prayer, "$resolvedNextName $resolvedNextTime")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val baseTime = SystemClock.elapsedRealtime() + remainingMillis
                setViewVisibility(R.id.ongoing_chronometer, View.VISIBLE)
                setViewVisibility(R.id.ongoing_fallback, View.GONE)
                setChronometerCountDown(R.id.ongoing_chronometer, true)
                setChronometer(R.id.ongoing_chronometer, baseTime, "متبقي %s", true)
            } else {
                setViewVisibility(R.id.ongoing_chronometer, View.GONE)
                setViewVisibility(R.id.ongoing_fallback, View.VISIBLE)
                val totalMins = (remainingMillis / (60 * 1000L)).toInt()
                val hrs = totalMins / 60
                val mins = totalMins % 60
                val remStr = if (hrs > 0) "متبقي $hrs س $mins د" else "متبقي $mins دقيقة"
                setTextViewText(R.id.ongoing_fallback, toArabicDigits(remStr))
            }

            setOnClickPendingIntent(R.id.ongoing_btn_refresh, pendingRefresh)
            setOnClickPendingIntent(R.id.ongoing_btn_open, pendingOpen)
        }

        // Expanded View
        val expandedView = RemoteViews(context.packageName, R.layout.notification_prayer_ongoing_expanded).apply {
            setTextViewText(R.id.ongoing_expanded_city, city)
            setTextViewText(R.id.ongoing_expanded_next_prayer, "$resolvedNextName $resolvedNextTime")

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val baseTime = SystemClock.elapsedRealtime() + remainingMillis
                setViewVisibility(R.id.ongoing_expanded_chronometer, View.VISIBLE)
                setViewVisibility(R.id.ongoing_expanded_fallback, View.GONE)
                setChronometerCountDown(R.id.ongoing_expanded_chronometer, true)
                setChronometer(R.id.ongoing_expanded_chronometer, baseTime, "متبقي %s", true)
            } else {
                setViewVisibility(R.id.ongoing_expanded_chronometer, View.GONE)
                setViewVisibility(R.id.ongoing_expanded_fallback, View.VISIBLE)
                val totalMins = (remainingMillis / (60 * 1000L)).toInt()
                val hrs = totalMins / 60
                val mins = totalMins % 60
                val remStr = if (hrs > 0) "متبقي $hrs س $mins د" else "متبقي $mins دقيقة"
                setTextViewText(R.id.ongoing_expanded_fallback, toArabicDigits(remStr))
            }

            setTextViewText(R.id.ongoing_time_fajr, fajr)
            setTextViewText(R.id.ongoing_time_shuruq, shuruq)
            setTextViewText(R.id.ongoing_time_dhuhr, dhuhr)
            setTextViewText(R.id.ongoing_time_asr, asr)
            setTextViewText(R.id.ongoing_time_maghrib, maghrib)
            setTextViewText(R.id.ongoing_time_isha, isha)

            val activeColor = Color.parseColor("#FFDF9A")
            val inactiveNameColor = Color.parseColor("#C0D0C8")
            val inactiveTimeColor = Color.parseColor("#FFFFFF")

            // Highlight next prayer
            setTextColor(R.id.ongoing_name_fajr, if (resolvedNextKey == "fajr") activeColor else inactiveNameColor)
            setTextColor(R.id.ongoing_time_fajr, if (resolvedNextKey == "fajr") activeColor else inactiveTimeColor)

            setTextColor(R.id.ongoing_name_shuruq, inactiveNameColor)
            setTextColor(R.id.ongoing_time_shuruq, inactiveTimeColor)

            setTextColor(R.id.ongoing_name_dhuhr, if (resolvedNextKey == "dhuhr") activeColor else inactiveNameColor)
            setTextColor(R.id.ongoing_time_dhuhr, if (resolvedNextKey == "dhuhr") activeColor else inactiveTimeColor)

            setTextColor(R.id.ongoing_name_asr, if (resolvedNextKey == "asr") activeColor else inactiveNameColor)
            setTextColor(R.id.ongoing_time_asr, if (resolvedNextKey == "asr") activeColor else inactiveTimeColor)

            setTextColor(R.id.ongoing_name_maghrib, if (resolvedNextKey == "maghrib") activeColor else inactiveNameColor)
            setTextColor(R.id.ongoing_time_maghrib, if (resolvedNextKey == "maghrib") activeColor else inactiveTimeColor)

            setTextColor(R.id.ongoing_name_isha, if (resolvedNextKey == "isha") activeColor else inactiveNameColor)
            setTextColor(R.id.ongoing_time_isha, if (resolvedNextKey == "isha") activeColor else inactiveTimeColor)

            setOnClickPendingIntent(R.id.ongoing_expanded_btn_refresh, pendingRefresh)
            setOnClickPendingIntent(R.id.ongoing_expanded_btn_open, pendingOpen)
        }

        val notificationBuilder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_siraty_notification)
            .setColor(Color.parseColor("#1B4D3E"))
            .setCustomContentView(smallView)
            .setCustomBigContentView(expandedView)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setContentIntent(pendingOpen)
            .setOngoing(true)
            .setAutoCancel(false)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        val notification = notificationBuilder.build().apply {
            flags = flags or android.app.Notification.FLAG_ONGOING_EVENT or android.app.Notification.FLAG_NO_CLEAR
        }

        try {
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
            nm?.notify(NOTIFICATION_ID, notification)
            Log.d("OngoingPrayer", "Updated ongoing prayer notification: next=$resolvedNextName $resolvedNextTime in $remainingMillis ms")
        } catch (e: Exception) {
            Log.w("OngoingPrayer", "Failed to notify ongoing prayer: ${e.message}")
        }
    }
}
