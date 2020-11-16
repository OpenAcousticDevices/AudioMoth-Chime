/****************************************************************************
 * AudioMothChimeConnector.kt
 * openacousticdevices.info
 * June 2020
 *****************************************************************************/

package info.openacousticdevices.audiomothchime

import java.util.*

class AudioMothChimeConnector {

    /* Useful constants */

    private val BITS_PER_BYTE: Int = 8
    private val BITS_IN_INT16: Int = 16
    private val BITS_IN_INT32: Int = 32

    private val LENGTH_OF_CHIME_PACKET: Int = 6
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

    private fun setTimeData(calendar: Calendar, state: State) {

        /* Calculate timestamp and offset */

        val timestamp: Int = ((calendar.timeInMillis + MILLISECONDS_IN_SECOND / 2 ) / MILLISECONDS_IN_SECOND).toInt()

        val timezoneMinutes: Int =
            (calendar.timeZone.rawOffset + calendar.timeZone.dstSavings) / SECONDS_IN_MINUTE / MILLISECONDS_IN_SECOND

        /* Time and timezone */

        setBits(state, timestamp, BITS_IN_INT32)

        setBits(state, timezoneMinutes, BITS_IN_INT16)

    }

    /* Public interface function */

    fun playTone(duration: Int) {

        audioMothChime.tone(duration, arrayOf("C5:1"))

    }

    fun playTime(calendar: Calendar) {

        /* Set up array */

        val data = Array<Int>(LENGTH_OF_CHIME_PACKET) { 0 }

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

        setTimeData(sendTime, state)

        /* Play the data */

        audioMothChime.chime(
            sendTime,
            data,
            arrayOf(
                "C5:1",
                "D5:1",
                "E5:1",
                "C5:3"
            )
        )

    }

    fun playTimeAndDeploymentID(calendar: Calendar, deploymentID: Array<Int>) {

        /* Check deployment ID length */

        if (deploymentID.size != LENGTH_OF_DEPLOYMENT_ID) {

            println("AUDIOMOTHCHIME_CONNECTOR: Deployment ID is incorrect length")

            return

        }

        /* Set up array */

        val size = LENGTH_OF_CHIME_PACKET + LENGTH_OF_DEPLOYMENT_ID

        val data = Array<Int>(size) { 0 }

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

        setTimeData(sendTime, state)

        /* Set the deployment ID */

        for (i in 0 until LENGTH_OF_DEPLOYMENT_ID) {

            data[size - 1 - i] = deploymentID[i] and 0xFF

        }

        /* Play the data */

        audioMothChime.chime(
            sendTime,
            data,
            arrayOf(
                "Eb5:1",
                "G5:1",
                "D5:1",
                "F#5:1",
                "Db5:1",
                "F5:1",
                "C5:1",
                "E5:5"
            )
        )

    }

}
