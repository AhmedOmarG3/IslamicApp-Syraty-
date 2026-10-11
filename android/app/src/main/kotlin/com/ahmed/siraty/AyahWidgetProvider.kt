package com.ahmed.siraty

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.util.Log
import android.util.TypedValue
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.util.Calendar

class AyahWidgetProvider : HomeWidgetProvider() {

    companion object {
        private const val MIDNIGHT_ALARM_REQ_CODE = 8881
    }

    /** Local-calendar day key mirroring [DailyAyahService.getDayKey] in Dart. */
    private fun todayDayKey(): Int {
        val cal = Calendar.getInstance()
        return cal.get(Calendar.YEAR) * 366 + cal.get(Calendar.DAY_OF_YEAR)
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

    /**
     * Calculates the deterministic day index matching Dart's
     * DateTime.difference(DateTime(2024, 1, 1)).inDays
     */
    private fun calculateDayIndex(calendar: Calendar): Int {
        val epoch = Calendar.getInstance().apply {
            set(2024, Calendar.JANUARY, 1, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val target = Calendar.getInstance().apply {
            timeInMillis = calendar.timeInMillis
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val diffMillis = target.timeInMillis - epoch.timeInMillis
        return (diffMillis / (24 * 60 * 60 * 1000L)).toInt()
    }

    /**
     * Autonomously ensures today's ayah is selected and written to SharedPreferences,
     * without needing the Flutter background isolate to run.
     */
    private fun ensureCurrentDayAyah(widgetData: SharedPreferences) {
        val currentDayKey = todayDayKey()
        val savedDayKey = widgetData.getInt("ayah_day_key", -1)

        if (savedDayKey == currentDayKey) {
            return
        }

        val jsonStr = widgetData.getString("daily_ayah_curated_json", null)
        val dayIndex = calculateDayIndex(Calendar.getInstance())

        var surahName = "طه"
        var ayahNumber = 114
        var verseTextRaw = "فَتَعَٰلَى ٱللَّهُ ٱلۡمَلِكُ ٱلۡحَقُّۗ وَلَا تَعۡجَلۡ بِٱلۡقُرۡءَانِ مِن قَبۡلِ أَن يُقۡضَىٰٓ إِلَيۡكَ وَحۡيُهُۥۖ وَقُل رَّبِّ زِدۡنِي عِلۡمٗا"

        if (!jsonStr.isNullOrEmpty()) {
            try {
                val array = JSONArray(jsonStr)
                if (array.length() > 0) {
                    val safeIndex = Math.abs(dayIndex) % array.length()
                    val obj = array.getJSONObject(safeIndex)
                    surahName = obj.optString("surahName", surahName)
                    ayahNumber = obj.optInt("ayahNumber", ayahNumber)
                    verseTextRaw = obj.optString("verseText", verseTextRaw)
                }
            } catch (e: Exception) {
                Log.w("AyahWidget", "Error parsing daily_ayah_curated_json: ${e.message}")
            }
        }

        val cleanText = verseTextRaw.replace("﴿", "").replace("﴾", "").trim()
        val formattedVerse = "﴿ $cleanText ﴾"
        val arabicAyah = toArabicDigits(ayahNumber.toString())
        val refText = "سورة $surahName · آية $arabicAyah"

        widgetData.edit()
            .putString("ayah_text", formattedVerse)
            .putString("ayah_ref", refText)
            .putInt("ayah_day_key", currentDayKey)
            .putInt("ayah_num", ayahNumber)
            .apply()

        Log.d("AyahWidget", "Autonomously updated ayah to dayKey=$currentDayKey: $refText")
    }

    /**
     * Schedules an exact RTC_WAKEUP alarm for midnight (00:00:05) every day
     * to wake the device and update the daily ayah widget.
     */
    private fun scheduleMidnightUpdate(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val midnight = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5)
            set(Calendar.MILLISECOND, 0)
        }

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val ids = appWidgetManager.getAppWidgetIds(ComponentName(context, AyahWidgetProvider::class.java))
        if (ids == null || ids.isEmpty()) return

        val intent = Intent(context, AyahWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            MIDNIGHT_ALARM_REQ_CODE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, midnight.timeInMillis, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, midnight.timeInMillis, pendingIntent)
            }
            Log.d("AyahWidget", "Scheduled midnight ayah update alarm for ${midnight.time}")
        } catch (e: Exception) {
            Log.w("AyahWidget", "Could not schedule exact midnight alarm: ${e.message}")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        if (action == Intent.ACTION_DATE_CHANGED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == Intent.ACTION_USER_PRESENT ||
            action == Intent.ACTION_BOOT_COMPLETED
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val ids = appWidgetManager.getAppWidgetIds(ComponentName(context, AyahWidgetProvider::class.java))
            if (ids != null && ids.isNotEmpty()) {
                val updateIntent = Intent(context, AyahWidgetProvider::class.java).apply {
                    this.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
                }
                super.onReceive(context, updateIntent)
                return
            }
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // 1. Ensure widgetData has today's ayah
        ensureCurrentDayAyah(widgetData)

        // 2. Schedule next midnight update
        scheduleMidnightUpdate(context)

        // 3. Render all widget instances
        renderViews(context, appWidgetManager, appWidgetIds, widgetData)
    }

    private fun renderViews(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        val rawVerse = widgetData.getString("ayah_text", "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾") ?: "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾"
        val trimmedVerse = rawVerse.replace("﴿", "").replace("﴾", "").trim()
        val verseText = "﴿ $trimmedVerse ﴾"
        val surahRef = widgetData.getString("ayah_ref", "سورة طه · آية ١١٤") ?: "سورة طه · آية ١١٤"

        // Dynamic text size calculation based on verse length so long verses fit gracefully
        val length = trimmedVerse.length
        val textSizeSp = when {
            length > 250 -> 12.5f
            length > 170 -> 14f
            length > 100 -> 15f
            length > 50 -> 16.5f
            else -> 18f
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ayah_widget_layout).apply {
                setTextViewText(R.id.widget_verse_text, verseText)
                setTextViewTextSize(R.id.widget_verse_text, TypedValue.COMPLEX_UNIT_SP, textSizeSp)
                setTextViewText(R.id.widget_ref_text, surahRef)

                // Load rendered image if available
                val imagePath = widgetData.getString("ayah_widget_image", null)
                if (!imagePath.isNullOrEmpty()) {
                    try {
                        val bitmap = android.graphics.BitmapFactory.decodeFile(imagePath)
                        if (bitmap != null) {
                            setImageViewBitmap(R.id.widget_rendered_image, bitmap)
                            setViewVisibility(R.id.widget_rendered_image, android.view.View.VISIBLE)
                            setViewVisibility(R.id.widget_fallback_container, android.view.View.GONE)
                        } else {
                            // Fallback if bitmap could not be decoded
                            setViewVisibility(R.id.widget_rendered_image, android.view.View.GONE)
                            setViewVisibility(R.id.widget_fallback_container, android.view.View.VISIBLE)
                        }
                    } catch (e: Exception) {
                        setViewVisibility(R.id.widget_rendered_image, android.view.View.GONE)
                        setViewVisibility(R.id.widget_fallback_container, android.view.View.VISIBLE)
                    }
                } else {
                    // No image path stored – show fallback layout
                    setViewVisibility(R.id.widget_rendered_image, android.view.View.GONE)
                    setViewVisibility(R.id.widget_fallback_container, android.view.View.VISIBLE)
                }

                // Tapping anywhere on the Widget opens Siraty directly
                val homeIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("siraty://daily-ayah?action=read")
                )
                setOnClickPendingIntent(R.id.widget_container, homeIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
