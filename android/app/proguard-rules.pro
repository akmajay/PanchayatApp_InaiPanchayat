# Flutter ProGuard Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.embedding.**  { *; }
-keep class io.flutter.plugin.editing.**  { *; }
-keep class io.flutter.plugin.platform.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase & Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.errorprone.annotations.**

# Keep Model classes for JSON serialization
-keep class com.inaipanchayat.app.features.**.models.** { *; }
-keepclassmembers class com.inaipanchayat.app.features.**.models.** { *; }

# Keep members used in serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep specific common types if needed
-keep public class * extends java.lang.Exception
-dontwarn com.google.android.play.**

# Additional library rules
-dontwarn javax.management.**
-dontwarn java.lang.management.**
-dontwarn org.apache.http.**

# Hive / Binary compatibility
-keep class com.mongodb.** { *; }
-dontwarn com.mongodb.**

# General
-ignorewarnings
-keepattributes Signature,Annotation,EnclosingMethod,InnerClasses
