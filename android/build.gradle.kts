plugins {
    java
}

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// ----------------------------
// Repositories
// ----------------------------
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ----------------------------
// Custom Build Directory
// ----------------------------
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ----------------------------
// Ensure subprojects evaluate after :app
// ----------------------------
subprojects {
    project.evaluationDependsOn(":app")
}

// ----------------------------
// Clean Task (updated)
// ----------------------------
tasks.named<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ----------------------------
// Disable default test tasks
// ----------------------------
tasks.matching { it.name == "test" }.configureEach {
    enabled = false
}
