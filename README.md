# AudioMoth Chime #

The AudioMoth-Chime library provide support to set the time and deployment ID of an AudioMoth using an acoustic tone. In both calls, it is also possible to set a location encoded as a floating point latitude and longitude.

### Android ###

The Kotlin Android library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```kotlin
	fun playTone(duration: Int)

	fun playTime(calendar: Calendar, latitude: Double, longitude: Double)
	
	fun playTimeAndDeploymentID(calendar: Calendar, latitude: Double?, longitude: Double?, deploymentID: Array<Int>)
```

Below is an example of their use:

```kotlin
	val chimeButton: Button = findViewById(R.id.chimeButton)

	val audioMothConnector = AudioMothChimeConnector()

	chimeButton.setOnClickListener{

		val calendar = Calendar.getInstance()

		Thread {

			audioMothConnector.playTime(calendar, null, null)

		}.start()

	}
```

### Javascript ###

The Javascript library contains two classes that must be included in the webpage. They define the global AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```javascript
	playTone(duration, callback);

	playTime(date, latitude, longitude, callback);
	
	playTimeAndDeploymentID(date, deploymentID, latitude, longitude, callback);
```

Below is an example of their use:

```javascript
	var audioMothChimeConnector = new AudioMothChimeConnector();

	document.getElementById("chime_button").addEventListener("click", function () {

		document.getElementById("chime_button").disabled = true;

		var date = new Date();

		audioMothChimeConnector.playTime(date, null, null, function () {

			document.getElementById("chime_button").disabled = false;

		});

	});
```

### iOS ###

The Swift iOS library contains two classes that must be included in the app. They define AudioMothChime and AudioMothChimeConnector objects. The latter exposes three public functions:

```swift
	func playTone(duration: Int)

	func playTime(date: Date, timezone: TimeZone, latitude: Double?, longitude: Double?)
	
	func playTimeAndDeploymentID(date: Date, timezone: TimeZone, latitude: Double?, longitude: Double?, deploymentID: Array<Int>)
```

Below is an example of their use:

```swift
	Button(action: {
		
		let date: Date = Date()
		
		let timezone: TimeZone = TimeZone.current
		
		audioMothChimeConnector.playTime(date: date, timezone: timezone, latitude: nil, longitude: nil)

	}) {
		Text("Play Chime")
	}
```
		
