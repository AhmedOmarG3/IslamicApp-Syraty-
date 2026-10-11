package com.ahmed.siraty

import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
class MainActivity: AudioServiceActivity() {

    companion object {
        var pendingIntentRoute: String? = null
    }

    private var appChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.getStringExtra("route")?.let { pendingIntentRoute = it }
        // Only wake screen/show when locked if specifically triggered as a full-screen alarm
        if (intent?.getBooleanExtra("is_alarm", false) == true) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
            }
        }
    }

    override fun onResume() {
        super.onResume()
        try {
            OngoingPrayerNotification.update(this)
        } catch (_: Exception) {}
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val route = intent.getStringExtra("route")
        if (!route.isNullOrEmpty()) {
            appChannel?.invokeMethod("onNavigateRoute", route)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(PrayerSchedulerPlugin())

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "siraty/app_channel")
        appChannel = channel
        channel.setMethodCallHandler { call, result ->
            if (call.method == "getInitialRoute") {
                val route = pendingIntentRoute
                pendingIntentRoute = null
                result.success(route)
            } else if (call.method == "openStoreListing") {
                val pkgName = applicationContext.packageName
                val marketUri = Uri.parse("market://details?id=$pkgName")
                val marketIntent = Intent(Intent.ACTION_VIEW, marketUri).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                try {
                    startActivity(marketIntent)
                    result.success(true)
                } catch (e: Exception) {
                    val webUri = Uri.parse("https://play.google.com/store/apps/details?id=$pkgName")
                    val webIntent = Intent(Intent.ACTION_VIEW, webUri).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    try {
                        startActivity(webIntent)
                        result.success(true)
                    } catch (e2: Exception) {
                        result.success(false)
                    }
                }
            } else if (call.method == "openUrl") {
                val url = call.argument<String>("url")
                if (!url.isNullOrEmpty()) {
                    try {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                } else {
                    result.success(false)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
