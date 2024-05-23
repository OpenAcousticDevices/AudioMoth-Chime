/****************************************************************************
 * AudioMothChimeConnector.kt
 * openacousticdevices.info
 * June 2020
 *****************************************************************************/

package info.openacousticdevices.audiomothchime

import java.util.*
import kotlin.math.*

class AudioMothChimeConnector {

    /* Useful constants */

    private val BITS_PER_BYTE: Int = 8
    private val BITS_IN_INT16: Int = 16
    private val BITS_IN_INT32: Int = 32

    private val BITS_IN_LATITUDE_AND_LONGITUDE: Int = 28

    private val LATITUDE_PRECISION: Double = 1000000.0
    private val LONGITUDE_PRECISION: Double = 500000.0

    private val LENGTH_OF_TIME: Int = 6
    private val LENGTH_OF_LOCATION: Int = 7
    private val LENGTH_OF_DEPLOYMENT_ID: Int = 8

    private val MILLISECONDS_IN_SECOND = 1000
    private val SECONDS_IN_MINUTE = 60
    private val MINIMUM_DELAY = 200
    private val ACOUSTIC_LAG = 100

    /* AudioMothChime object */

    private val audioMothChime =
        AudioMothChime()

    /* Data class to keep track of packet contents */

    private data class State(var bytes: Array<Int>, var index: Int)

    /* Private functions to set data */

    private fun setBit(state: State, value: Boolean) {

        val byte = state.index / BITS_PER_BYTE
        val bit = state.index % BITS_PER_BYTE

        if (value) {

            state.bytes[byte] = state.bytes[byte] or (1 shl bit)

        }

        state.index += 1

    }

    private fun setBits(state: State, value: Int, length: Int) {

        for (i in 0 until length) {

            val mask = (1 shl i)

            setBit(state, (value and mask) == mask)

        }

    }

    private fun encodeTime(calendar: Calendar, state: State) {

        /* Calculate timestamp and offset */

        val timestamp: Int = ((calendar.timeInMillis + MILLISECONDS_IN_SECOND / 2 ) / MILLISECONDS_IN_SECOND).toInt()

        val timezoneMinutes: Int =
            (calendar.timeZone.rawOffset + calendar.timeZone.dstSavings) / SECONDS_IN_MINUTE / MILLISECONDS_IN_SECOND

        /* Time and timezone */

        setBits(state, timestamp, BITS_IN_INT32)

        setBits(state, timezoneMinutes, BITS_IN_INT16)

    }

    private fun encodeLocation(latitude: Double, longitude: Double, state: State) {

        val intLatitude: Int = (round(max(-90.0, min(90.0, latitude)) * LATITUDE_PRECISION)).toInt()

        val intLongitude: Int = (round(max(-180.0, min(180.0, longitude)) * LONGITUDE_PRECISION)).toInt()

        setBits(state, intLatitude, BITS_IN_LATITUDE_AND_LONGITUDE)

        setBits(state, intLongitude, BITS_IN_LATITUDE_AND_LONGITUDE)

    }

    private fun encodeDeploymentID(deploymentID: Array<Int>, state: State) {

        for (i in 0 until LENGTH_OF_DEPLOYMENT_ID) {

            state.bytes[state.index / BITS_PER_BYTE] = deploymentID[LENGTH_OF_DEPLOYMENT_ID - 1 - i] and 0xFF

            state.index += BITS_PER_BYTE

        }

    }

    /* Public interface function */

    fun playTone(duration: Int) {

        audioMothChime.tone(duration, arrayOf("C5:1"))

    }

    fun playTime(calendar: Calendar, latitude: Double?, longitude: Double?) {

        /* Set up array */

        val locationValid: Boolean = latitude != null && longitude != null

        val length: Int = LENGTH_OF_TIME + if (locationValid) LENGTH_OF_LOCATION else 0

        val data = Array<Int>(length) { 0 }

        val state =
            State(
                data,
                0
            )

        /* Set the time date */

        var delay = MILLISECONDS_IN_SECOND - calendar.getTimeInMillis() % MILLISECONDS_IN_SECOND - ACOUSTIC_LAG

        if (delay < MINIMUM_DELAY) { delay += MILLISECONDS_IN_SECOND }

        val sendTime = Calendar.getInstance()

        sendTime.setTimeInMillis(calendar.getTimeInMillis() + delay)

        encodeTime(sendTime, state)

        if (locationValid) encodeLocation(latitude!!, longitude!!, state)

        /* Play the data */

        var tune = arrayOf(
            "C5:1",
            "D5:1",
            "E5:1",
            "C5:3"
        )

        if (locationValid) tune += arrayOf(
            "D5:1",
            "E5:1",
            "C5:3"
        )

        audioMothChime.chime(
            sendTime,
            data,
            tune
        )

    }

    fun playTimeAndDeploymentID(calendar: Calendar, latitude: Double?, longitude: Double?, deploymentID: Array<Int>) {

        /* Check deployment ID length */

        if (deploymentID.size != LENGTH_OF_DEPLOYMENT_ID) {

            println("AUDIOMOTH CHIME CONNECTOR: Deployment ID is incorrect length")

            return

        }

        /* Set up array */

        val locationValid: Boolean = latitude != null && longitude != null

        val length: Int = LENGTH_OF_TIME + LENGTH_OF_DEPLOYMENT_ID + if (locationValid) LENGTH_OF_LOCATION else 0

        val data = Array<Int>(length) { 0 }

        val state =
            State(
                data,
                0
            )

        /* Set the time date */

        var delay = MILLISECONDS_IN_SECOND - calendar.getTimeInMillis() % MILLISECONDS_IN_SECOND - ACOUSTIC_LAG

        if (delay < MINIMUM_DELAY) { delay += MILLISECONDS_IN_SECOND }

        val sendTime = Calendar.getInstance()

        sendTime.setTimeInMillis(calendar.getTimeInMillis() + delay)

        encodeTime(sendTime, state)

        if (locationValid) encodeLocation(latitude!!, longitude!!, state)

        encodeDeploymentID(deploymentID, state)

        /* Play the data */

        var tune = arrayOf(
            "Eb5:1",
            "G5:1",
            "D5:1",
            "F#5:1",
            "Db5:1",
            "F5:1",
            "C5:1",
            "E5:5"
        )

        if (locationValid) tune += arrayOf(
            "Db5:1",
            "F5:1", 
            "C5:1", 
            "E5:4"
        )

        audioMothChime.chime(
            sendTime,
            data,
            tune
        )

    }

}
