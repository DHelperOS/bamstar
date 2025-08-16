plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// Load keystore properties if present (android/key.properties)
// rootProject points to the Android project root (bamstar/android), so use "key.properties"
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
} else {
    println("Keystore properties file not found: ${keystorePropertiesFile.path}")
}

android {
    namespace = "co.kr.bamstar.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId = "co.kr.bamstar.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
    signingConfigs {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias") ?: "bamstar_key"
                keyPassword = keystoreProperties.getProperty("keyPassword") ?: "p951219@"
        // storeFile is defined relative to the Android root; resolve from rootProject
        storeFile = rootProject.file(keystoreProperties.getProperty("storeFile") ?: "app/bamstar_keystore.jks")
                storePassword = keystoreProperties.getProperty("storePassword") ?: "p951219@"
            }
        }

        release {
            signingConfig = signingConfigs.getByName("release")
            // minifyEnabled false by default for debug; adjust proguard if needed
            // Ensure resource shrinking is explicitly disabled for now to avoid
            // the Gradle error about removing unused resources when code shrinking
            // is not enabled.
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            // Use the same keystore for debug builds as requested.
            signingConfig = signingConfigs.getByName("release")
            isDebuggable = true
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
