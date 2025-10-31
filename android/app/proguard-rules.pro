# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ✅ Google Play Core (IMPORTANT pour résoudre l'erreur)
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# HTTP/OkHttp
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Billing
-keep class com.android.billingclient.** { *; }
-dontwarn com.android.billingclient.**

# Networking
-keep class com.squareup.okhttp.** { *; }
-keep interface com.squareup.okhttp.** { *; }


# Garder les informations de débogage
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Garder les numéros de ligne pour les crashs
-keepattributes LineNumberTable,SourceFile

# Garder les annotations
-keepattributes *Annotation*
-keepattributes Exceptions