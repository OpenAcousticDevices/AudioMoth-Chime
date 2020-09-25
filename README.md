# AudioMoth Chime #

A library which provides support for setting the time and deployment ID of an AudioMoth using an acoustic tone.

Compatible with [standard AudioMoth firmware](https://github.com/OpenAcousticDevices/AudioMoth-Firmware-Basic/releases) 1.5.0 and later.

## Usage ##

### Android ###

The Kotlin Android library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes two public functions:

```kotlin
fun playTime(calendar: Calendar)

fun playTimeAndDeploymentID(calendar: Calendar, deploymentID: Array<Int>)
```

Below is an example of their use:

```kotlin
val chimeButton: Button = findViewById(R.id.chimeButton)

val audioMothConnector = AudioMothChimeConnector()

chimeButton.setOnClickListener{

	val calendar = Calendar.getInstance()

	Thread {

		audioMothConnector.playTime(calendar)

	}.start()

}
```

### Javascript ###

The Javascript library contains two classes that must be included in the webpage. They define the global AudioMothChime and AudioMothChimeConnector objects. The latter exposes two public functions:

```javascript
playTime(callback);

playTimeAndDeploymentID(deploymentID, callback);
```

Below is an example of their use:

```javascript
var audioMothChimeConnector = new AudioMothChimeConnector();

document.getElementById("chime_button").addEventListener("click", function () {

	document.getElementById("chime_button").disabled = true;

	audioMothChimeConnector.playTime(function () {

		document.getElementById("chime_button").disabled = false;

	});

});
```

### iOS ###

The Swift iOS library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes two public functions:

```swift
func playTime(date: Date, timezone: TimeZone)

func playTimeAndDeploymentID(date: Date, timezone: TimeZone, deploymentID: Array<Int>)
```

Below is an example of their use:

```swift
Button(action: {
	
	let date: Date = Date()
	
	let timezone: TimeZone = TimeZone.current
	
	audioMothChimeConnector.playTime(date: date, timezone: timezone)

}) {
	Text("Play Chime")
}
```

### Related Repositories ###
* [AudioMoth Firmware Basic](https://github.com/OpenAcousticDevices/AudioMoth-Firmware-Basic)
* [AudioMoth Time App](https://github.com/OpenAcousticDevices/AudioMoth-Time-App)

### License ###

Copyright 2019 [Open Acoustic Devices](http://www.openacousticdevices.info/).

[MIT license](http://www.openacousticdevices.info/license).
