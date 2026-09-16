package com.ahmed.siraty

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import java.util.Calendar

class AyahWidgetProvider : HomeWidgetProvider() {

    /** Local-calendar day key mirroring [DailyAyahService.getDayKey] in Dart. */
    private fun todayDayKey(): Int {
        val cal = Calendar.getInstance()
        return cal.get(Calendar.YEAR) * 366 + cal.get(Calendar.DAY_OF_YEAR)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        // If the cached ayah is from a previous day, ask the Flutter
        // background isolate to re-render today's ayah.
        // We throttle requests to at least 30 minutes to prevent flickering / rebuild loops
        val savedDayKey = widgetData.getInt("ayah_day_key", -1)
        val lastAttempt = widgetData.getLong("ayah_last_update_attempt", 0L)
        val now = System.currentTimeMillis()
        val throttleMs = 30 * 60 * 1000L // 30 minutes

        if (savedDayKey != todayDayKey() && (now - lastAttempt > throttleMs)) {
            widgetData.edit().putLong("ayah_last_update_attempt", now).apply()
            try {
                HomeWidgetBackgroundIntent.getBroadcast(
                    context,
                    Uri.parse("siraty://daily-ayah?action=update")
                ).send()
            } catch (e: Exception) {
                // PendingIntent.send can throw (e.g. canceled); the widget
                // will refresh on next app launch regardless.
            }
        }

        val verseText = widgetData.getString("ayah_text", "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾") ?: "﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾"
        val surahRef = widgetData.getString("ayah_ref", "سورة طه · آية ١١٤") ?: "سورة طه · آية ١١٤"

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ayah_widget_layout).apply {
                setTextViewText(R.id.widget_verse_text, verseText)
                setTextViewText(R.id.widget_ref_text, surahRef)

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
