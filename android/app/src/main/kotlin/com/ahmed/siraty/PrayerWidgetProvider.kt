package com.ahmed.siraty

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {

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

    private fun toArabicDigits(input: String): String {
        val english = charArrayOf('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
        val arabic = charArrayOf('٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩')
        var result = input
        for (i in english.indices) {
            result = result.replace(english[i], arabic[i])
        }
        return result
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        try {
            val rawCity = widgetData.getString("prayer_city", "القاهرة") ?: "القاهرة"
            val city = if (rawCity.startsWith("📍")) rawCity else "📍 $rawCity"

            // Fallback times if widget is placed before app opens
            val fajr = widgetData.getString("prayer_fajr_time", "٠٤:٣٥") ?: "٠٤:٣٥"
            val dhuhr = widgetData.getString("prayer_dhuhr_time", "١١:٥٨") ?: "١١:٥٨"
            val asr = widgetData.getString("prayer_asr_time", "٠٣:٢٦") ?: "٠٣:٢٦"
            val maghrib = widgetData.getString("prayer_maghrib_time", "٠٦:٠٤") ?: "٠٦:٠٤"
            val isha = widgetData.getString("prayer_isha_time", "٠٧:٢٢") ?: "٠٧:٢٢"

            var resolvedNextKey = widgetData.getString("prayer_next_key", "dhuhr") ?: "dhuhr"
            var resolvedNextName = widgetData.getString("prayer_next_name", "الظهر") ?: "الظهر"
            var resolvedNextTime = widgetData.getString("prayer_next_time", dhuhr) ?: dhuhr

            val savedNextEpoch = getSafeLong(widgetData, "prayer_next_epoch")
            val savedNextName = widgetData.getString("prayer_next_name", null)
            val savedNextTime = widgetData.getString("prayer_next_time", null)
            val savedNextKey = widgetData.getString("prayer_next_key", null)

            val fajrEpoch = getSafeLong(widgetData, "prayer_fajr_epoch")
            val dhuhrEpoch = getSafeLong(widgetData, "prayer_dhuhr_epoch")
            val asrEpoch = getSafeLong(widgetData, "prayer_asr_epoch")
            val maghribEpoch = getSafeLong(widgetData, "prayer_maghrib_epoch")
            val ishaEpoch = getSafeLong(widgetData, "prayer_isha_epoch")

            var targetEpoch = 0L
            val now = System.currentTimeMillis()

            if (savedNextEpoch > now && !savedNextName.isNullOrEmpty() && !savedNextTime.isNullOrEmpty()) {
                resolvedNextName = savedNextName
                resolvedNextTime = savedNextTime
                resolvedNextKey = savedNextKey ?: "dhuhr"
                targetEpoch = savedNextEpoch
            } else if (fajrEpoch > 0L && dhuhrEpoch > 0L && asrEpoch > 0L && maghribEpoch > 0L && ishaEpoch > 0L) {
                when {
                    now < fajrEpoch -> {
                        resolvedNextKey = "fajr"
                        resolvedNextName = "الفجر"
                        resolvedNextTime = fajr
                        targetEpoch = fajrEpoch
                    }
                    now < dhuhrEpoch -> {
                        resolvedNextKey = "dhuhr"
                        resolvedNextName = "الظهر"
                        resolvedNextTime = dhuhr
                        targetEpoch = dhuhrEpoch
                    }
                    now < asrEpoch -> {
                        resolvedNextKey = "asr"
                        resolvedNextName = "العصر"
                        resolvedNextTime = asr
                        targetEpoch = asrEpoch
                    }
                    now < maghribEpoch -> {
                        resolvedNextKey = "maghrib"
                        resolvedNextName = "المغرب"
                        resolvedNextTime = maghrib
                        targetEpoch = maghribEpoch
                    }
                    now < ishaEpoch -> {
                        resolvedNextKey = "isha"
                        resolvedNextName = "العشاء"
                        resolvedNextTime = isha
                        targetEpoch = ishaEpoch
                    }
                    else -> {
                        resolvedNextKey = "fajr"
                        resolvedNextName = "الفجر"
                        resolvedNextTime = fajr
                        targetEpoch = fajrEpoch + (24 * 60 * 60 * 1000L)
                    }
                }
            }

            val remainingMillis = targetEpoch - now
            val isFuture = targetEpoch > now && remainingMillis > 0

            val remainingText: String = if (isFuture) {
                val totalSeconds = (remainingMillis / 1000).toInt()
                val hours = totalSeconds / 3600
                val minutes = (totalSeconds % 3600) / 60
                val seconds = totalSeconds % 60
                val hStr = String.format("%02d", hours)
                val mStr = String.format("%02d", minutes)
                val sStr = String.format("%02d", seconds)
                val timerStr = if (hours > 0) "$hStr:$mStr:$sStr" else "$mStr:$sStr"
                "متبقي ${toArabicDigits(timerStr)}"
            } else {
                "حان وقت الصلاة"
            }

            val nextKey = resolvedNextKey
            val nextName = resolvedNextName
            val nextTime = resolvedNextTime

            val activeGold = Color.parseColor("#FFD98E")
            val inactiveLabel = Color.parseColor("#B4D4C8")
            val activeTime = Color.parseColor("#FFFFFF")
            val inactiveTime = Color.parseColor("#F0F4F2")

            appWidgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout).apply {
                    setTextViewText(R.id.widget_prayer_city, city)
                    setTextViewText(R.id.widget_prayer_next, nextName)
                    setTextViewText(R.id.widget_prayer_next_time, nextTime)

                    if (isFuture) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            val baseTime = SystemClock.elapsedRealtime() + remainingMillis
                            setViewVisibility(R.id.widget_prayer_countdown, View.VISIBLE)
                            setViewVisibility(R.id.widget_prayer_remaining, View.GONE)
                            setChronometerCountDown(R.id.widget_prayer_countdown, true)
                            setChronometer(R.id.widget_prayer_countdown, baseTime, "متبقي %s", true)
                        } else {
                            setViewVisibility(R.id.widget_prayer_countdown, View.GONE)
                            setViewVisibility(R.id.widget_prayer_remaining, View.VISIBLE)
                            setTextViewText(R.id.widget_prayer_remaining, remainingText)
                        }
                    } else {
                        setViewVisibility(R.id.widget_prayer_countdown, View.GONE)
                        setViewVisibility(R.id.widget_prayer_remaining, View.VISIBLE)
                        setTextViewText(R.id.widget_prayer_remaining, "حان وقت الصلاة")
                    }

                    setTextViewText(R.id.widget_time_fajr, fajr)
                    setTextViewText(R.id.widget_time_dhuhr, dhuhr)
                    setTextViewText(R.id.widget_time_asr, asr)
                    setTextViewText(R.id.widget_time_maghrib, maghrib)
                    setTextViewText(R.id.widget_time_isha, isha)

                    // Highlight the next prayer row with active border & gradient drawable
                    setInt(R.id.widget_item_fajr, "setBackgroundResource", if (nextKey == "fajr") R.drawable.widget_item_active_bg else R.drawable.widget_row_bg)
                    setInt(R.id.widget_item_dhuhr, "setBackgroundResource", if (nextKey == "dhuhr") R.drawable.widget_item_active_bg else R.drawable.widget_row_bg)
                    setInt(R.id.widget_item_asr, "setBackgroundResource", if (nextKey == "asr") R.drawable.widget_item_active_bg else R.drawable.widget_row_bg)
                    setInt(R.id.widget_item_maghrib, "setBackgroundResource", if (nextKey == "maghrib") R.drawable.widget_item_active_bg else R.drawable.widget_row_bg)
                    setInt(R.id.widget_item_isha, "setBackgroundResource", if (nextKey == "isha") R.drawable.widget_item_active_bg else R.drawable.widget_row_bg)

                    setTextColor(R.id.widget_label_fajr, if (nextKey == "fajr") activeGold else inactiveLabel)
                    setTextColor(R.id.widget_label_dhuhr, if (nextKey == "dhuhr") activeGold else inactiveLabel)
                    setTextColor(R.id.widget_label_asr, if (nextKey == "asr") activeGold else inactiveLabel)
                    setTextColor(R.id.widget_label_maghrib, if (nextKey == "maghrib") activeGold else inactiveLabel)
                    setTextColor(R.id.widget_label_isha, if (nextKey == "isha") activeGold else inactiveLabel)

                    setTextColor(R.id.widget_time_fajr, if (nextKey == "fajr") activeTime else inactiveTime)
                    setTextColor(R.id.widget_time_dhuhr, if (nextKey == "dhuhr") activeTime else inactiveTime)
                    setTextColor(R.id.widget_time_asr, if (nextKey == "asr") activeTime else inactiveTime)
                    setTextColor(R.id.widget_time_maghrib, if (nextKey == "maghrib") activeTime else inactiveTime)
                    setTextColor(R.id.widget_time_isha, if (nextKey == "isha") activeTime else inactiveTime)

                    // Clicking anywhere on the widget launches Siraty directly to the Prayer page
                    val openIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("siraty://prayer?action=open")
                    )
                    setOnClickPendingIntent(R.id.prayer_widget_container, openIntent)
                }

                appWidgetManager.updateAppWidget(widgetId, views)
            }

            // Schedule an exact alarm to wake up the widget the exact second the next prayer arrives
            if (isFuture) {
                try {
                    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
                    val updateIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                    }
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        9901,
                        updateIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    if (alarmManager != null) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, targetEpoch + 1000L, pendingIntent)
                        } else {
                            alarmManager.setExact(AlarmManager.RTC_WAKEUP, targetEpoch + 1000L, pendingIntent)
                        }
                    }
                } catch (_: Exception) {}
            }
        } catch (e: Exception) {
            // Safe fallback
        }
    }
}

