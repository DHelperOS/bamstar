import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension

// Add Google Services classpath so the plugin can generate values.xml from
// google-services.json during the Android app build.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure BuildConfig is generated for all Android modules (AGP 8+: default may be disabled)
subprojects {
    plugins.withId("com.android.application") {
        extensions.configure(ApplicationExtension::class.java) {
            buildFeatures.apply {
                buildConfig = true
            }
        }
    }
    plugins.withId("com.android.library") {
        extensions.configure(LibraryExtension::class.java) {
            // Provide a fallback namespace for libraries that don't declare one (AGP 8+ requirement)
            if (namespace.isNullOrBlank()) {
                // Safe unique default: based on project path/name; dashes are invalid in package names
                val base = project.path.replace(":", ".").replace("-", "_").trim('.').ifEmpty { project.name }
                namespace = "co.kr.bamstar.thirdparty.$base"
            }
            buildFeatures.apply {
                buildConfig = true
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
