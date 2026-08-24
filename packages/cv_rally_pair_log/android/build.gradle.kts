group = "com.rallypair.cv_rally_pair_log"
version = "1.0-SNAPSHOT"

plugins {
    id("com.android.library")
    id("kotlin-android")
}

android {
    namespace = "com.rallypair.cv_rally_pair_log"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    sourceSets.getByName("main").java.srcDirs("src/main/kotlin")

    defaultConfig { minSdk = 24 }
}
