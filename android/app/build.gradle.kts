import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Assinatura de release (fase 08). A keystore e as senhas ficam em
// android/key.properties (fora do git; modelo em key.properties.example). O João
// cria a keystore com o `keytool` de docs/PENDENCIAS-JOAO.md. Sem o arquivo, o
// build de release sai assinado com a chave de DEBUG, com aviso: serve para
// provar que o pipeline compila, nunca para subir na Play.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
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

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                logger.warn(
                    "AVISO: android/key.properties não existe; o release sai assinado com a chave de DEBUG. " +
                        "Não envie este build para a Google Play (docs/RELEASE.md)."
                )
                signingConfig = signingConfigs.getByName("debug")
            }
            // R8: encolhe e ofusca. As regras extras (flutter_local_notifications) ficam em proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
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
