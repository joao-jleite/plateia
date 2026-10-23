# Regras do R8 para o release (fase 08). O Flutter já traz as dele.

# flutter_local_notifications serializa a notificação agendada com Gson:
# sem isto, o lembrete reagendado depois de reiniciar o aparelho perde os campos.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
