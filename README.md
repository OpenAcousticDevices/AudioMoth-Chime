# AudioMoth Chime #

The AudioMoth-Chime library provide support to set the time and the 8-byte deployment ID of an AudioMoth using an acoustic tone. These will automatically work with version 1.5.0 of the AudioMoth-Firmware-Basic and later.

### Android ###

The Kotlin Android library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```kotlin
	fun playTone(duration: Int)

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

The Javascript library contains two classes that must be included in the webpage. They define the global AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```javascript
	playTone(duration, callback);

	playTime(date, callback);
	
	playTimeAndDeploymentID(date, deploymentID, callback);
```

Below is an example of their use:

```javascript
	var audioMothChimeConnector = new AudioMothChimeConnector();

	document.getElementById("chime_button").addEventListener("click", function () {

		document.getElementById("chime_button").disabled = true;

		var date = new Date();

		audioMothChimeConnector.playTime(function () {

			document.getElementById("chime_button").disabled = false;

		});

	});
```

### iOS ###

The Swift iOS library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```swift
	func playTone(duration: Int)

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
