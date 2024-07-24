plugins {
	id("approach.android.feature")
	id("approach.android.library.compose")
}

android {
	namespace = "ca.josephroque.bowlingcompanion.feature.bowlerform"
}

dependencies {
	implementation(projects.feature.bowlerform.ui)
	implementation(libs.kotlinx.datetime)
}
