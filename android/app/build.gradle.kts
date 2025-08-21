plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.github.el_apps.escritura"
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
        applicationId = "com.github.el_apps.escritura"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
       release {
           keyAlias = keystoreProperties['keyAlias']
           keyPassword = keystoreProperties['keyPassword']
           storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword = keystoreProperties['storePassword']
       }
    }
    buildTypes {
       release {
           signingConfig = signingConfigs.release
       }
    }
}

flutter {
    source = "../.."
}
