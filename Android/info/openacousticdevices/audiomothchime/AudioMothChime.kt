/****************************************************************************
 * AudioMothChime.kt
 * openacousticdevices.info
 * June 2020
 *****************************************************************************/

package info.openacousticdevices.audiomothchime

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Build

import kotlin.math.*

class AudioMothChime {

    /* General constants */

    private val SPEED_FACTOR: Float = 1.0f

    private val USE_HAMMING_CODE: Boolean = true

    private val CARRIER_FREQUENCY: Int = 18000

    private val NUMBER_OF_STOP_BITS: Int = 8

    private val NUMBER_OF_START_BITS: Int = 16

    /* Tone timing constants */

    private val BIT_RISE: Float = 0.0005f / SPEED_FACTOR
    private val BIT_FALL: Float = 0.0005f / SPEED_FACTOR

    private val LOW_BIT_SUSTAIN: Float = 0.004f / SPEED_FACTOR
    private val HIGH_BIT_SUSTAIN: Float = 0.009f / SPEED_FACTOR
    private val START_STOP_BIT_SUSTAIN: Float = 0.0065f / SPEED_FACTOR

    private val NOTE_RISE_DURATION: Float = 0.030f / SPEED_FACTOR
    private val NOTE_FALL_DURATION: Float = 0.030f / SPEED_FACTOR
    private val NOTE_LONG_FALL_DURATION: Float = 0.090f / SPEED_FACTOR

    private val MIN_TONE_DURATION: Int = 500
    private val MAX_TONE_DURATION: Int = 60000

    /* Note parsing constants */

    private val REGEX = Regex(
        "^(C|C#|Db|D|D#|Eb|E|F|F#|Gb|G|G#|Ab|A|A#|Bb|B)([0-9]):([1-9])$"
    )

    private val FREQUENCY_LOOKUP = mapOf(
        "C0" to 16,
        "C#0" to 17,
        "Db0" to 17,
        "D0" to 18,
        "D#0" to 19,
        "Eb0" to 19,
        "E0" to 21,
        "F0" to 22,
        "F#0" to 23,
        "Gb0" to 23,
        "G0" to 24,
        "G#0" to 26,
        "Ab0" to 26,
        "A0" to 28,
        "A#0" to 29,
        "Bb0" to 29,
        "B0" to 31,
        "C1" to 33,
        "C#1" to 35,
        "Db1" to 35,
        "D1" to 37,
        "D#1" to 39,
        "Eb1" to 39,
        "E1" to 41,
        "F1" to 44,
        "F#1" to 46,
        "Gb1" to 46,
        "G1" to 49,
        "G#1" to 52,
        "Ab1" to 52,
        "A1" to 55,
        "A#1" to 58,
        "Bb1" to 58,
        "B1" to 62,
        "C2" to 65,
        "C#2" to 69,
        "Db2" to 69,
        "D2" to 73,
        "D#2" to 78,
        "Eb2" to 78,
        "E2" to 82,
        "F2" to 87,
        "F#2" to 92,
        "Gb2" to 92,
        "G2" to 98,
        "G#2" to 104,
        "Ab2" to 104,
        "A2" to 110,
        "A#2" to 117,
        "Bb2" to 117,
        "B2" to 123,
        "C3" to 131,
        "C#3" to 139,
        "Db3" to 139,
        "D3" to 147,
        "D#3" to 156,
        "Eb3" to 156,
        "E3" to 165,
        "F3" to 175,
        "F#3" to 185,
        "Gb3" to 185,
        "G3" to 196,
        "G#3" to 208,
        "Ab3" to 208,
        "A3" to 220,
        "A#3" to 233,
        "Bb3" to 233,
        "B3" to 247,
        "C4" to 262,
        "C#4" to 277,
        "Db4" to 277,
        "D4" to 294,
        "D#4" to 311,
        "Eb4" to 311,
        "E4" to 330,
        "F4" to 349,
        "F#4" to 370,
        "Gb4" to 370,
        "G4" to 392,
        "G#4" to 415,
        "Ab4" to 415,
        "A4" to 440,
        "A#4" to 466,
        "Bb4" to 466,
        "B4" to 494,
        "C5" to 523,
        "C#5" to 554,
        "Db5" to 554,
        "D5" to 587,
        "D#5" to 622,
        "Eb5" to 622,
        "E5" to 659,
        "F5" to 698,
        "F#5" to 740,
        "Gb5" to 740,
        "G5" to 784,
        "G#5" to 831,
        "Ab5" to 831,
        "A5" to 880,
        "A#5" to 932,
        "Bb5" to 932,
        "B5" to 988,
        "C6" to 1047,
        "C#6" to 1109,
        "Db6" to 1109,
        "D6" to 1175,
        "D#6" to 1245,
        "Eb6" to 1245,
        "E6" to 1319,
        "F6" to 1397,
        "F#6" to 1480,
        "Gb6" to 1480,
        "G6" to 1568,
        "G#6" to 1661,
        "Ab6" to 1661,
        "A6" to 1760,
        "A#6" to 1865,
        "Bb6" to 1865,
        "B6" to 1976,
        "C7" to 2093,
        "C#7" to 2217,
        "Db7" to 2217,
        "D7" to 2349,
        "D#7" to 2489,
        "Eb7" to 2489,
        "E7" to 2637,
        "F7" to 2794,
        "F#7" to 2960,
        "Gb7" to 2960,
        "G7" to 3136,
        "G#7" to 3322,
        "Ab7" to 3322,
        "A7" to 3520,
        "A#7" to 3729,
        "Bb7" to 3729,
        "B7" to 3951,
        "C8" to 4186,
        "C#8" to 4435,
        "Db8" to 4435,
        "D8" to 4699,
        "D#8" to 4978,
        "Eb8" to 4978,
        "E8" to 5274,
        "F8" to 5588,
        "F#8" to 5920,
        "Gb8" to 5920,
        "G8" to 6272,
        "G#8" to 6645,
        "Ab8" to 6645,
        "A8" to 7040,
        "A#8" to 7459,
        "Bb8" to 7459,
        "B8" to 7902,
        "C9" to 8372,
        "C#9" to 8870,
        "Db9" to 8870,
        "D9" to 9397,
        "D#9" to 9956,
        "Eb9" to 9956,
        "E9" to 10548,
        "F9" to 11175,
        "F#9" to 11840,
        "Gb9" to 11840,
        "G9" to 12544,
        "G#9" to 13290,
        "Ab9" to 13290,
        "A9" to 14080,
        "A#9" to 14917,
        "Bb9" to 14917,
        "B9" to 15804
    )

    /* Encoding constant */

    private val HAMMING_CODE = arrayOf(
        arrayOf(0, 0, 0, 0, 0, 0, 0),
        arrayOf(1, 1, 1, 0, 0, 0, 0),
        arrayOf(1, 0, 0, 1, 1, 0, 0),
        arrayOf(0, 1, 1, 1, 1, 0, 0),
        arrayOf(0, 1, 0, 1, 0, 1, 0),
        arrayOf(1, 0, 1, 1, 0, 1, 0),
        arrayOf(1, 1, 0, 0, 1, 1, 0),
        arrayOf(0, 0, 1, 0, 1, 1, 0),
        arrayOf(1, 1, 0, 1, 0, 0, 1),
        arrayOf(0, 0, 1, 1, 0, 0, 1),
        arrayOf(0, 1, 0, 0, 1, 0, 1),
        arrayOf(1, 0, 1, 0, 1, 0, 1),
        arrayOf(1, 0, 0, 0, 0, 1, 1),
        arrayOf(0, 1, 1, 0, 0, 1, 1),
        arrayOf(0, 0, 0, 1, 1, 1, 1),
        arrayOf(1, 1, 1, 1, 1, 1, 1)
    )

    /* Data classes */

    private data class State(
        var amplitudePhase: Float = 0.0f,
        var x: Float = 1.0f,
        var y: Float = 0.0f
    )

    private data class Note(var frequency: Int = 523, var duration: Int = 1)

    private data class CRC16(var low: Int = 0, var high: Int = 0)

    /* Functions to calculate CRC code */

    private fun updateCRC16(crc: Int, incr: Int): Int {

        val CRC_POLY: Int = 0x1021

        val xor: Int = (crc shr 15) and 0xFFFF
        var out: Int = (crc shl 1) and 0xFFFF

        if (incr > 0) out += 1

        if (xor > 0) out = out xor CRC_POLY

        return out

    }

    private fun createCRC16(bytes: Array<Int>): CRC16 {

        var crc: Int = 0

        bytes.forEach {
            for (x in 7 downTo 0) {
                crc = updateCRC16(crc, (it and (1 shl x)))
            }
        }

        for (i in 0 until 16) {
            crc = updateCRC16(crc, 0)
        }

        return CRC16(
            crc and 0xFF,
            (crc shr 8) and 0xFF
        )

    }

    /* Function to encode bytes */

    private fun encode(bytes: ArrayList<Int>): ArrayList<Int> {

        val bitSequence = arrayListOf<Int>()

        bytes.forEach {

            if (USE_HAMMING_CODE) {

                val low: Int = (it and 0x0F)
                val high: Int = (it and 0xF0) shr 4

                for (x in 0 until 7) {
                    bitSequence.add(HAMMING_CODE[low][x])
                    bitSequence.add(HAMMING_CODE[high][x])
                }

            } else {

                for (x in 0 until 8) {

                    val mask = (0x01 shl x)

                    bitSequence.add(if ((it and mask) == mask) 1 else 0)

                }

            }

        }

        return bitSequence

    }

    /* Functions to parses notes */

    private fun parseNotes(noteArray: Array<String>): ArrayList<Note> {

        val notes = ArrayList<Note>()

        noteArray.forEach {

            if (REGEX.matches(it)) {

                val frequency: Int? = FREQUENCY_LOOKUP.get(it.split(":")[0])

                val duration = it.split(":")[1].toInt()

                frequency?.let {
                    notes.add(
                        Note(
                            frequency,
                            duration
                        )
                    )
                }

            }

        }

        if (notes.size == 0) notes.add(Note())

        return notes

    }

    /* Functions to generate waveforms */

    private fun createWaveformComponent(
        waveform: ArrayList<Float>,
        state: State,
        sampleRate: Int,
        frequency: Int,
        phase: Float,
        rampUp: Float,
        sustain: Float,
        rampDown: Float
    ) {

        val samplesInRampUp: Int = round(rampUp * sampleRate).toInt()

        val samplesInSustain: Int = round(sustain * sampleRate).toInt()

        val samplesInRampDown: Int = round(rampDown * sampleRate).toInt()

        val theta: Float = 2f * Math.PI.toFloat() * frequency.toFloat() / sampleRate.toFloat()

        for (k in 0 until samplesInRampUp + samplesInSustain + samplesInRampDown) {

            if (k < samplesInRampUp) {
                state.amplitudePhase =
                    min(
                        Math.PI.toFloat() / 2.0f,
                        state.amplitudePhase + Math.PI.toFloat() / 2.0f / samplesInRampUp.toFloat()
                    )
            }

            if (k >= samplesInRampUp + samplesInSustain) {
                state.amplitudePhase =
                    max(
                        0.0f,
                        state.amplitudePhase - Math.PI.toFloat() / 2.0f / samplesInRampDown.toFloat()
                    )
            }

            val volume: Float = sin(state.amplitudePhase).pow(2.0f)

            waveform.add(volume * phase * state.x)

            val x: Float = state.x * cos(theta) - state.y * sin(theta)

            val y: Float = state.x * sin(theta) + state.y * cos(theta)

            state.x = x

            state.y = y

        }

    }

    private fun createWaveform(
        sampleRate: Int,
        duration: Int?,
        byteArray: Array<Int>?,
        noteArray: Array<String>
    ): ArrayList<Float> {

        val waveform = ArrayList<Float>()

        val waveform1 = ArrayList<Float>()

        val waveform2 = ArrayList<Float>()

        /* Generate note sequence */

        val notes: ArrayList<Note> = parseNotes(noteArray)

        /* Counters used during sound waveform creation */

        var state: State =
            State()

        var phase: Float = 1.0f

        /* Initial start bits */

        val startBits: Int = if (duration == null) NUMBER_OF_START_BITS else floor(max(MIN_TONE_DURATION, min(MAX_TONE_DURATION, duration)) / 1000.0f / (BIT_RISE + START_STOP_BIT_SUSTAIN + BIT_FALL)).toInt();

        for (i in 0 until startBits) {

            createWaveformComponent(
                waveform1,
                state,
                sampleRate,
                CARRIER_FREQUENCY,
                phase,
                BIT_RISE,
                START_STOP_BIT_SUSTAIN,
                BIT_FALL
            )

            phase *= -1.0f

        }

        if (byteArray != null) {

            /* Generate bit sequence */

            val crc: CRC16 = createCRC16(byteArray)

            val bytes: ArrayList<Int> = ArrayList<Int>()

            byteArray.forEach { bytes.add(it) }

            bytes.add(crc.low)
            bytes.add(crc.high)

            val bitSequence: ArrayList<Int> = encode(bytes)

            /* Display output */

            println("AUDIOMOTHCHIME: " + bytes.size + " bytes")

            println("AUDIOMOTHCHIME: " + bitSequence.size + " bits")

            /* Data bits */

            bitSequence.forEach {

                val bitDuration = if (it == 1) HIGH_BIT_SUSTAIN else LOW_BIT_SUSTAIN

                createWaveformComponent(
                    waveform1,
                    state,
                    sampleRate,
                    CARRIER_FREQUENCY,
                    phase,
                    BIT_RISE,
                    bitDuration,
                    BIT_FALL
                )

                phase *= -1.0f

            }

            /* Stop bits */

            for (i in 0 until NUMBER_OF_STOP_BITS) {

                createWaveformComponent(
                    waveform1,
                    state,
                    sampleRate,
                    CARRIER_FREQUENCY,
                    phase,
                    BIT_RISE,
                    START_STOP_BIT_SUSTAIN,
                    BIT_FALL
                )

                phase *= -1.0f

            }

        }

        /* Reset counter */

        state = State()

        /* Calculate note duration */

        var sumOfDurations: Int = 0

        notes.forEach { sumOfDurations += it.duration }

        val noteDuration: Float =
            (waveform1.size.toFloat() / sampleRate.toFloat() - notes.size.toFloat() * (NOTE_RISE_DURATION + NOTE_FALL_DURATION) + NOTE_FALL_DURATION - NOTE_LONG_FALL_DURATION) / sumOfDurations.toFloat()

        /* Create note waveform */

        notes.forEachIndexed { index, note ->

            val noteFallDuration =
                if (index == notes.size - 1) NOTE_LONG_FALL_DURATION else NOTE_FALL_DURATION

            createWaveformComponent(
                waveform2,
                state,
                sampleRate,
                note.frequency,
                1.0f,
                NOTE_RISE_DURATION,
                noteDuration * note.duration,
                noteFallDuration
            )

        }

        /* Sum the waveforms */

        val length = min(waveform1.size, waveform2.size)

        for (i in 0 until length) waveform.add(waveform1[i] / 4.0f + waveform2[i] / 2.0f)

        return waveform

    }

    /* Function to generate sound */

    private fun play(
        duration: Int?, 
        byteArray: Array<Int>?, 
        noteArray: Array<String>
    ) {

        /* Configure AudioTrack */

        val sampleRate: Int = AudioTrack.getNativeOutputSampleRate(AudioManager.STREAM_MUSIC)

        val minBufferSize = AudioTrack.getMinBufferSize(
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT
        )

        val player = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            AudioTrack.Builder()
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                        .build()
                )
                .setAudioFormat(
                    AudioFormat.Builder()
                        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                        .setSampleRate(sampleRate)
                        .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                        .build()
                )
                .setBufferSizeInBytes(minBufferSize)
                .build()
        } else {
            AudioTrack(
                AudioManager.STREAM_MUSIC, sampleRate,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                minBufferSize,
                AudioTrack.MODE_STATIC
            )
        }

        /* Generate waveform */

        val waveform: ArrayList<Float> = createWaveform(sampleRate, duration, byteArray, noteArray)

        /* Play waveform */

        val buffer = ShortArray(waveform.size)

        waveform.forEachIndexed { index, fl ->
            buffer[index] = (fl * Short.MAX_VALUE).toShort()
        }

        println("AUDIOMOTHCHIME: Start")

        player.play()

        player.write(buffer, 0, waveform.size)

        println("AUDIOMOTHCHIME: Done")

    }

    /* Public chime function */

    fun tone(duration: Int, noteArray: Array<String>) {

        play(duration, null, noteArray)

    }

    fun chime(byteArray: Array<Int>, noteArray: Array<String>) {

        play(null, byteArray, noteArray)

    }

}
