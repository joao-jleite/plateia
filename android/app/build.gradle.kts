plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.joaojleite.watchlog"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications (fase 07) usa java.time: exige desugaring no minSdk 24.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Imutável na Play Store (docs/ARQUITETURA.md §2). "Plateia" é só o rótulo.
        applicationId = "io.github.joaojleite.watchlog"
        // Android 7+ (§2): cobre a base ativa e simplifica App Links.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Assinado com a chave de debug até a fase 08 criar a keystore de release
            // (key.properties fora do git).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
