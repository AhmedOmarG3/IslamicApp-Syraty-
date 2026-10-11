# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Custom Android Native Classes (Widgets, Receivers, Services)
-keep class com.ahmed.siraty.** { *; }

# Audio Background & Foreground Services (just_audio & audio_service)
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.just_audio.** { *; }
-dontwarn com.ryanheise.audioservice.**
-dontwarn com.ryanheise.just_audio.**

# AndroidX & Support MediaSession Callbacks (Play/Pause/Stop notification controls)
-keep class androidx.media.** { *; }
-keep class androidx.media.session.** { *; }
-keep class android.support.v4.media.** { *; }
-keep class android.support.v4.media.session.** { *; }
-keepclassmembers class * extends android.support.v4.media.session.MediaSessionCompat$Callback { *; }


# Google Play Core splitinstall / deferred components suppressions (when not using dynamic features)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Preserve raw audio and drawable resources from shrinking/renaming
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R$raw { *; }

