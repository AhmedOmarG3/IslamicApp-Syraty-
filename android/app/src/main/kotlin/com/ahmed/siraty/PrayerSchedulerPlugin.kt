package com.ahmed.siraty

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class PrayerSchedulerPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null

    companion object {
        const val CHANNEL_NAME = "siraty/prayer_scheduler"
        const val PREFS_NAME = "siraty_prayer_alarms"
        const val KEY_SCHEDULED_ALARMS = "scheduled_alarm_ids"
        const val KEY_SCHEDULED_PAYLOADS = "scheduled_payloads_json"
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "scheduleEvents" -> {
                val rawEvents = call.argument<List<Map<String, Any>>>("events") ?: emptyList()
                val success = scheduleAlarms(rawEvents)
                result.success(success)
            }
            "cancelAllPrayerEvents" -> {
                cancelAllAlarms()
                result.success(null)
            }
            "canScheduleExactAlarms" -> {
                result.success(canScheduleExact())
            }
            "requestExactAlarmPermission" -> {
                val opened = requestExactAlarmPermission()
                result.success(opened)
            }
            "requestNotificationPermission" -> {
                requestNotificationPermission(result)
            }
            "hasNotificationPermission" -> {
                result.success(hasNotificationPermission())
            }
            "isIgnoringBatteryOptimizations" -> {
                result.success(isIgnoringBatteryOptimizations())
            }
            "requestIgnoreBatteryOptimizations" -> {
                result.success(requestIgnoreBatteryOptimizations())
            }
            "updateWidget" -> {
                triggerWidgetUpdate()
                result.success(null)
            }
            "isAutoStartSupported" -> {
                result.success(isAutoStartSupported())
            }
            "openAutoStartSettings" -> {
                result.success(openAutoStartSettings())
            }
            "getDeviceManufacturer" -> {
                result.success(getDeviceManufacturer())
            }
            else -> result.notImplemented()
        }
    }

    private fun canScheduleExact(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager?.canScheduleExactAlarms() ?: false
        } else {
            true
        }
    }

    private fun requestExactAlarmPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !canScheduleExact()) {
            return try {
                val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:${context.packageName}")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                true
            } catch (e: Exception) {
                Log.w("SiratyScheduler", "Cannot open exact alarm settings: ${e.message}")
                false
            }
        }
        return false
    }

    private fun isIgnoringBatteryOptimizations(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
            powerManager?.isIgnoringBatteryOptimizations(context.packageName) ?: true
        } else {
            true
        }
    }

    private fun requestIgnoreBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !isIgnoringBatteryOptimizations()) {
            return try {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                true
            } catch (e: Exception) {
                Log.w("SiratyScheduler", "Cannot open ignore battery opt: ${e.message}")
                false
            }
        }
        return false
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val activity = activityBinding?.activity
            if (activity != null) {
                val granted = ContextCompat.checkSelfPermission(
                    activity,
                    android.Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED

                if (!granted) {
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(android.Manifest.permission.POST_NOTIFICATIONS),
                        101
                    )
                }
                result.success(granted)
                return
            }
        }
        result.success(true)
    }

    private fun hasNotificationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(
                context,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun getDeviceManufacturer(): String {
        val m = Build.MANUFACTURER ?: ""
        return if (m.isNotEmpty()) m.substring(0, 1).uppercase() + m.substring(1) else "Android"
    }

    private fun isAutoStartSupported(): Boolean {
        val manufacturer = (Build.MANUFACTURER ?: "").lowercase()
        val brand = (Build.BRAND ?: "").lowercase()
        val oems = listOf(
            "xiaomi", "redmi", "poco",
            "huawei", "honor",
            "oppo", "realme",
            "vivo", "iqoo",
            "transsion", "infinix", "tecno", "itel",
            "oneplus", "asus", "samsung"
        )
        for (oem in oems) {
            if (manufacturer.contains(oem) || brand.contains(oem)) {
                return true
            }
        }
        val pm = context.packageManager ?: return false
        for (intent in getAutoStartIntents()) {
            val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0)).isNotEmpty()
            } else {
                @Suppress("DEPRECATION")
                pm.queryIntentActivities(intent, 0).isNotEmpty()
            }
            if (resolved) return true
        }
        return false
    }

    private fun getAutoStartIntents(): List<Intent> {
        val intents = mutableListOf<Intent>()

        // Xiaomi / Redmi / POCO
        intents.add(Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")))
        intents.add(Intent("miui.intent.action.OP_AUTO_START").addCategory(Intent.CATEGORY_DEFAULT))
        intents.add(Intent().setComponent(ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerSettings")))

        // Transsion (Infinix / Tecno / Itel)
        intents.add(Intent().setComponent(ComponentName("com.transsion.phonemanager", "com.transsion.phonemanager.view.AutoStartListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.transsion.phonemanager", "com.itel.autostart.AutoStartActivity")))
        intents.add(Intent().setComponent(ComponentName("com.transsion.phonemanager", "com.transsion.phonemanager.view.AppAutoStartListActivity")))

        // Huawei / Honor
        intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity")))
        intents.add(Intent().setComponent(ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")))

        // Oppo / Realme
        intents.add(Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.coloros.safecenter", "com.coloros.safecenter.startupapp.StartupAppListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.oplus.battery", "com.oplus.battery.AppListActivity")))

        // Vivo / iQOO
        intents.add(Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity")))
        intents.add(Intent().setComponent(ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")))
        intents.add(Intent().setComponent(ComponentName("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")))

        // Samsung
        intents.add(Intent().setComponent(ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity")))
        intents.add(Intent().setComponent(ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity")))

        // OnePlus
        intents.add(Intent().setComponent(ComponentName("com.oneplus.security", "com.oneplus.security.chainlaunch.view.ChainLaunchAppListActivity")))

        // Asus
        intents.add(Intent().setComponent(ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.entry.FunctionActivity")))
        intents.add(Intent().setComponent(ComponentName("com.asus.mobilemanager", "com.asus.mobilemanager.autostart.AutoStartActivity")))

        return intents
    }

    private fun openAutoStartSettings(): Boolean {
        val pm = context.packageManager
        for (intent in getAutoStartIntents()) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm?.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0))?.isNotEmpty() == true
            } else {
                @Suppress("DEPRECATION")
                pm?.queryIntentActivities(intent, 0)?.isNotEmpty() == true
            }
            if (resolved) {
                try {
                    context.startActivity(intent)
                    Log.d("SiratyScheduler", "Launched autostart activity: ${intent.component}")
                    return true
                } catch (e: Exception) {
                    Log.w("SiratyScheduler", "Could not start autostart activity: ${e.message}")
                }
            }
        }

        // Fallback: App Details Settings
        return try {
            val fallback = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:${context.packageName}")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(fallback)
            Log.d("SiratyScheduler", "Launched app details fallback for autostart")
            true
        } catch (e: Exception) {
            Log.e("SiratyScheduler", "Could not open app details: ${e.message}")
            false
        }
    }

    private fun scheduleAlarms(events: List<Map<String, Any>>): Boolean {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        // Cancel previously scheduled alarms
        cancelAllAlarms()

        val scheduledIds = mutableSetOf<String>()
        val jsonArray = JSONArray()
        val canExact = canScheduleExact()
        val now = System.currentTimeMillis()

        Log.d("SiratyScheduler", "Scheduling ${events.size} events. canScheduleExact=$canExact")

        for (event in events) {
            val alarmId = (event["alarmId"] as? Number)?.toInt() ?: continue
            val epochMillis = (event["epochMillis"] as? Number)?.toLong() ?: continue
            val prayerKey = event["prayerKey"] as? String ?: ""
            val eventType = event["eventType"] as? String ?: "reminder"
            val reciterRawResource = event["reciterRawResource"] as? String ?: "adhan_makkah"
            val title = event["title"] as? String ?: ""
            val body = event["body"] as? String ?: ""

            // Skip past events
            if (epochMillis <= now) {
                continue
            }

            val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
                putExtra(PrayerAlarmReceiver.EXTRA_ALARM_ID, alarmId)
                putExtra(PrayerAlarmReceiver.EXTRA_PRAYER_KEY, prayerKey)
                putExtra(PrayerAlarmReceiver.EXTRA_EVENT_TYPE, eventType)
                putExtra(PrayerAlarmReceiver.EXTRA_RECITER_RAW, reciterRawResource)
                putExtra(PrayerAlarmReceiver.EXTRA_TITLE, title)
                putExtra(PrayerAlarmReceiver.EXTRA_BODY, body)
            }

            val pendingIntent = PendingIntent.getBroadcast(
                context,
                alarmId,
                intent,
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
                        Log.d("SiratyScheduler", "✅ Scheduled ADHAN (setAlarmClock) id=$alarmId at $epochMillis for $prayerKey")
                        scheduled = true
                    } catch (e: SecurityException) {
                        Log.w("SiratyScheduler", "setAlarmClock SecurityException for id=$alarmId: ${e.message}. Using fallback.")
                    } catch (e: Exception) {
                        Log.e("SiratyScheduler", "setAlarmClock failed for id=$alarmId: ${e.message}")
                    }
                }

                // Fallback to setAndAllowWhileIdle if setAlarmClock failed or canExact is false
                if (!scheduled) {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        } else {
                            alarmManager.set(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        }
                        Log.d("SiratyScheduler", "✅ Scheduled ADHAN (fallback setAndAllowWhileIdle) id=$alarmId at $epochMillis for $prayerKey")
                        scheduled = true
                    } catch (e: Exception) {
                        Log.e("SiratyScheduler", "Failed fallback for adhan id=$alarmId: ${e.message}", e)
                    }
                }
            } else {
                // Reminder event
                try {
                    if (canExact) {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        } else {
                            alarmManager.setExact(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        }
                        Log.d("SiratyScheduler", "✅ Scheduled REMINDER (exact) id=$alarmId at $epochMillis for $prayerKey")
                    } else {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        } else {
                            alarmManager.set(AlarmManager.RTC_WAKEUP, epochMillis, pendingIntent)
                        }
                        Log.d("SiratyScheduler", "✅ Scheduled REMINDER (inexact) id=$alarmId at $epochMillis for $prayerKey")
                    }
                    scheduled = true
                } catch (e: Exception) {
                    Log.e("SiratyScheduler", "Failed to schedule reminder id=$alarmId: ${e.message}", e)
                }
            }

            if (scheduled) {
                scheduledIds.add(alarmId.toString())
                val obj = JSONObject().apply {
                    put("alarmId", alarmId)
                    put("epochMillis", epochMillis)
                    put("prayerKey", prayerKey)
                    put("eventType", eventType)
                    put("reciterRawResource", reciterRawResource)
                    put("title", title)
                    put("body", body)
                }
                jsonArray.put(obj)
            }
        }

        prefs.edit()
            .putStringSet(KEY_SCHEDULED_ALARMS, scheduledIds)
            .putString(KEY_SCHEDULED_PAYLOADS, jsonArray.toString())
            .apply()

        Log.d("SiratyScheduler", "Total scheduled alarms saved: ${scheduledIds.size}")
        return true
    }

    private fun cancelAllAlarms() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedIds = prefs.getStringSet(KEY_SCHEDULED_ALARMS, emptySet()) ?: emptySet()

        for (idStr in savedIds) {
            val id = idStr.toIntOrNull() ?: continue
            val intent = Intent(context, PrayerAlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                context,
                id,
                intent,
                PendingIntent.FLAG_NO_CREATE or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }

        prefs.edit().remove(KEY_SCHEDULED_ALARMS).remove(KEY_SCHEDULED_PAYLOADS).apply()
    }

    private fun triggerWidgetUpdate() {
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetComponent = ComponentName(context, PrayerWidgetProvider::class.java)
            val ids = appWidgetManager.getAppWidgetIds(widgetComponent)
            if (ids != null && ids.isNotEmpty()) {
                val intent = Intent(context, PrayerWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                context.sendBroadcast(intent)
            }
            // Also update Ayah widget
            val ayahComponent = ComponentName(context, AyahWidgetProvider::class.java)
            val ayahIds = appWidgetManager.getAppWidgetIds(ayahComponent)
            if (ayahIds != null && ayahIds.isNotEmpty()) {
                val ayahIntent = Intent(context, AyahWidgetProvider::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ayahIds)
                }
                context.sendBroadcast(ayahIntent)
            }
        } catch (e: Exception) {
            Log.w("SiratyScheduler", "Widget update failed: ${e.message}")
        }
    }
}
