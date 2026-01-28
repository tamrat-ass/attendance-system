# Flutter ProGuard Rules for Size Optimization

# Keep Flutter Engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Basic obfuscation
-obfuscationdictionary proguard-dict.txt
-classobfuscationdictionary proguard-dict.txt
-packageobfuscationdictionary proguard-dict.txt

# Remove logging
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** d(...);
    public static *** e(...);
}

# Basic optimization
-optimizationpasses 3
-allowaccessmodification

# Remove unused resources
-dontwarn **
-ignorewarnings