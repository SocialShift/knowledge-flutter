# Flutter ProGuard Rules

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep permission-related classes
-keep class android.permission.** { *; }

# Keep network related classes
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
-keep class com.google.gson.** { *; }

# Keep video player related classes
-keep class video_player.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

# Keep cached network image classes
-keep class cached_network_image.** { *; }

# Keep Supabase classes (if using)
-keep class io.supabase.** { *; }

# Keep HTTP client classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }

# Don't warn about missing classes
-dontwarn okio.**
-dontwarn retrofit2.**
-dontwarn io.flutter.**

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Preserve all annotations
-keepattributes *Annotation*

# Keep all public classes and methods
-keep public class * {
    public protected *;
} 