package com.ahmed.siraty

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import org.json.JSONArray

class PrayerBootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == Intent.ACTION_MY_PACKAGE_REPLACED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == "android.intent.action.QUICKBOOT_POWERON" ||
            action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            rescheduleRemainingAlarms(context)
            OngoingPrayerNotification.update(context)
        }
    }

    private fun rescheduleRemainingAlarms(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val prefs = context.getSharedPreferences(PrayerSchedulerPlugin.PREFS_NAME, Context.MODE_PRIVATE)
        val jsonStr = prefs.getString(PrayerSchedulerPlugin.KEY_SCHEDULED_PAYLOADS, null) ?: return

        try {
            val jsonArray = JSONArray(jsonStr)
            val now = System.currentTimeMillis()
            val remainingIds = mutableSetOf<String>()
            val remainingArray = JSONArray()

            val canExact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                alarmManager.canScheduleExactAlarms()
            } else {
                true
            }

            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val epochMillis = obj.getLong("epochMillis")

                // Only reschedule if still in the future
                if (epochMillis > now) {
                    val alarmId = obj.getInt("alarmId")
                    val prayerKey = obj.optString("prayerKey", "")
                    val eventType = obj.optString("eventType", "reminder")
                    val reciterRawResource = obj.optString("reciterRawResource", "adhan_makkah")
                    val title = obj.optString("title", "")
                    val body = obj.optString("body", "")

                    val alarmIntent = Intent(context, PrayerAlarmReceiver::class.java).apply {
                        putExtra(PrayerAlarmReceiver.EXTRA_ALARM_ID, alarmId)
                        putExtra(PrayerAlarmReceiver.EXTRA_PRAYER_KEY, prayerKey)
                        putExtra(PrayerAlarmReceiver.EXTRA_EVENT_TYPE, eventType)
                        putExtra(PrayerAlarmReceiver.EXTRA_RECITER_RAW, reciterRawResource)
                        putExtra(PrayerAlarmReceiver.EXTRA_TITLE, title)
                        putExtra(PrayerAlarmReceiver.EXTRA_BODY, body)
                        putExtra(PrayerAlarmReceiver.EXTRA_SCHEDULED_TIME, epochMillis)
                    }

                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        alarmId,
                        alarmIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                    )

                    var scheduled = false
                    if (eventType == "adhan") {
                        if (canExact) {
                            try {
                                val showIntent = PendingIntent.getActivity(
                                    context,
                                    alarmId + 30_000,
                                    Intent(context, MainActivity::class.java).apply {
                                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                                    },
                                    PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                                )
                                val alarmClockInfo = AlarmManager.AlarmClockInfo(epochMillis, showIntent)
                                alarmManager.setAlarmClock(alarmClockInfo, pendingIntent)
                                Log.d("SiratyBoot", "✅ Rescheduled ADHAN (setAlarmClock) id=$alarmId for $prayerKey")
                                scheduled = true
                            } catch (e: SecurityException) {
                                Log.w("SiratyBoot", "SecurityException on setAlarmClock for id=$alarmId: ${e.message}. Using fallback.")
                            } catch (e: Exception) {
                                Log.e("SiratyBoot", "Failed setAlarmClock for id=$alarmId: ${e.message}")
                            }
                        }

                        if (!scheduled) {
                            try {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                } else {
                                    alarmManager.set(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                }
                                Log.d("SiratyBoot", "✅ Rescheduled ADHAN (fallback setAndAllowWhileIdle) id=$alarmId for $prayerKey")
                                scheduled = true
                            } catch (e: Exception) {
                                Log.e("SiratyBoot", "Failed fallback reschedule for adhan id=$alarmId: ${e.message}", e)
                            }
                        }
                    } else {
                        try {
                            if (canExact) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                } else {
                                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                }
                                Log.d("SiratyBoot", "✅ Rescheduled REMINDER (exact) id=$alarmId for $prayerKey")
                            } else {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                } else {
                                    alarmManager.set(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                                }
                                Log.d("SiratyBoot", "✅ Rescheduled REMINDER (inexact) id=$alarmId for $prayerKey")
                            }
                            scheduled = true
                        } catch (e: Exception) {
                            Log.e("SiratyBoot", "Failed reschedule reminder id=$alarmId: ${e.message}", e)
                        }
                    }

                    if (scheduled) {
                        remainingIds.add(alarmId.toString())
                        remainingArray.put(obj)
                    }
                }
            }

            prefs.edit()
                .putStringSet(PrayerSchedulerPlugin.KEY_SCHEDULED_ALARMS, remainingIds)
                .putString(PrayerSchedulerPlugin.KEY_SCHEDULED_PAYLOADS, remainingArray.toString())
                .apply()

            // Trigger widget update
            try {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val widgetComponent = ComponentName(context, PrayerWidgetProvider::class.java)
                val ids = appWidgetManager.getAppWidgetIds(widgetComponent)
                if (ids != null && ids.isNotEmpty()) {
                    val widgetIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                    }
                    context.sendBroadcast(widgetIntent)
                }
            } catch (_: Exception) {}

            Log.d("SiratyBoot", "Rescheduled ${remainingIds.size} alarms after boot/timezone change")
        } catch (e: Exception) {
            Log.w("SiratyBoot", "Failed to reschedule alarms: ${e.message}")
        }
    }
}
