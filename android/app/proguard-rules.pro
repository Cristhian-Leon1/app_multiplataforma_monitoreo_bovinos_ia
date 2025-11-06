# Keep all TensorFlow Lite classes and prevent R8 from removing them
-keep class org.tensorflow.lite.** { *; }
-keep interface org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Keep TensorFlow Lite GPU delegate classes (specific fix for the error)
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep interface org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.lite.gpu.**

# Keep TensorFlow Lite NNAPI delegate classes  
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep interface org.tensorflow.lite.nnapi.** { *; }
-dontwarn org.tensorflow.lite.nnapi.**

# Keep TensorFlow Lite Flex delegate classes
-keep class org.tensorflow.lite.flex.** { *; }
-keep interface org.tensorflow.lite.flex.** { *; }
-dontwarn org.tensorflow.lite.flex.**

# Keep all delegate classes
-keep class org.tensorflow.lite.delegates.** { *; }
-keep interface org.tensorflow.lite.delegates.** { *; }
-dontwarn org.tensorflow.lite.delegates.**

# Keep Flatbuffers (used by TensorFlow Lite)
-keep class com.google.flatbuffers.** { *; }
-dontwarn com.google.flatbuffers.**

# Keep native method signatures
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep tflite_flutter plugin classes - more specific rules
-keep class org.tensorflow.lite.flutter.tflite.** { *; }
-keep class tflite_flutter.** { *; }
-dontwarn tflite_flutter.**

# Keep model loading related classes
-keep class * extends org.tensorflow.lite.Interpreter { *; }
-keep class * extends org.tensorflow.lite.InterpreterApi { *; }

# Keep Tensor related classes
-keep class org.tensorflow.lite.Tensor { *; }
-keep class org.tensorflow.lite.DataType { *; }

# Additional safety rules for reflection-based access
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Signature
-keepattributes Exceptions
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Disable R8 full mode for better compatibility with TensorFlow Lite
# This can be enabled by adding android.enableR8.fullMode=false to gradle.properties