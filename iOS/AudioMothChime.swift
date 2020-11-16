/****************************************************************************
* AudioMothChime.swift
* openacousticdevices.info
* June 2020
*****************************************************************************/

import Foundation
import AVFoundation

var data: Data!
var audioPlayer: AVAudioPlayer!

class AudioMothChime {

    /* General constants */

    private let SPEED_FACTOR: Float = 1.0

    private let USE_HAMMING_CODE: Bool = true

    private let CARRIER_FREQUENCY: Int = 18000

    private let NUMBER_OF_STOP_BITS: Int = 8

    private let NUMBER_OF_START_BITS: Int = 16

    /* Tone timing constants */

    private var BIT_RISE: Float = 0.0005
    private var BIT_FALL: Float = 0.0005

    private var LOW_BIT_SUSTAIN: Float = 0.004
    private var HIGH_BIT_SUSTAIN: Float = 0.009
    private var START_STOP_BIT_SUSTAIN: Float = 0.0065

    private var NOTE_RISE_DURATION: Float = 0.030
    private var NOTE_FALL_DURATION: Float = 0.030
    private var NOTE_LONG_FALL_DURATION: Float = 0.090
    
    private var MIN_TONE_DURATION: Int = 500
    private var MAX_TONE_DURATION: Int = 60000

    /* Note parsing constants */

    private let REGEX: String = "^(C|C#|Db|D|D#|Eb|E|F|F#|Gb|G|G#|Ab|A|A#|Bb|B)([0-9]):([1-9])$"

    private let FREQUENCY_LOOKUP: [String: Int] = [
        "C0": 16,
        "C#0": 17,
        "Db0": 17,
        "D0": 18,
        "D#0": 19,
        "Eb0": 19,
        "E0": 21,
        "F0": 22,
        "F#0": 23,
        "Gb0": 23,
        "G0": 24,
        "G#0": 26,
        "Ab0": 26,
        "A0": 28,
        "A#0": 29,
        "Bb0": 29,
        "B0": 31,
        "C1": 33,
        "C#1": 35,
        "Db1": 35,
        "D1": 37,
        "D#1": 39,
        "Eb1": 39,
        "E1": 41,
        "F1": 44,
        "F#1": 46,
        "Gb1": 46,
        "G1": 49,
        "G#1": 52,
        "Ab1": 52,
        "A1": 55,
        "A#1": 58,
        "Bb1": 58,
        "B1": 62,
        "C2": 65,
        "C#2": 69,
        "Db2": 69,
        "D2": 73,
        "D#2": 78,
        "Eb2": 78,
        "E2": 82,
        "F2": 87,
        "F#2": 92,
        "Gb2": 92,
        "G2": 98,
        "G#2": 104,
        "Ab2": 104,
        "A2": 110,
        "A#2": 117,
        "Bb2": 117,
        "B2": 123,
        "C3": 131,
        "C#3": 139,
        "Db3": 139,
        "D3": 147,
        "D#3": 156,
        "Eb3": 156,
        "E3": 165,
        "F3": 175,
        "F#3": 185,
        "Gb3": 185,
        "G3": 196,
        "G#3": 208,
        "Ab3": 208,
        "A3": 220,
        "A#3": 233,
        "Bb3": 233,
        "B3": 247,
        "C4": 262,
        "C#4": 277,
        "Db4": 277,
        "D4": 294,
        "D#4": 311,
        "Eb4": 311,
        "E4": 330,
        "F4": 349,
        "F#4": 370,
        "Gb4": 370,
        "G4": 392,
        "G#4": 415,
        "Ab4": 415,
        "A4": 440,
        "A#4": 466,
        "Bb4": 466,
        "B4": 494,
        "C5": 523,
        "C#5": 554,
        "Db5": 554,
        "D5": 587,
        "D#5": 622,
        "Eb5": 622,
        "E5": 659,
        "F5": 698,
        "F#5": 740,
        "Gb5": 740,
        "G5": 784,
        "G#5": 831,
        "Ab5": 831,
        "A5": 880,
        "A#5": 932,
        "Bb5": 932,
        "B5": 988,
        "C6": 1047,
        "C#6": 1109,
        "Db6": 1109,
        "D6": 1175,
        "D#6": 1245,
        "Eb6": 1245,
        "E6": 1319,
        "F6": 1397,
        "F#6": 1480,
        "Gb6": 1480,
        "G6": 1568,
        "G#6": 1661,
        "Ab6": 1661,
        "A6": 1760,
        "A#6": 1865,
        "Bb6": 1865,
        "B6": 1976,
        "C7": 2093,
        "C#7": 2217,
        "Db7": 2217,
        "D7": 2349,
        "D#7": 2489,
        "Eb7": 2489,
        "E7": 2637,
        "F7": 2794,
        "F#7": 2960,
        "Gb7": 2960,
        "G7": 3136,
        "G#7": 3322,
        "Ab7": 3322,
        "A7": 3520,
        "A#7": 3729,
        "Bb7": 3729,
        "B7": 3951,
        "C8": 4186,
        "C#8": 4435,
        "Db8": 4435,
        "D8": 4699,
        "D#8": 4978,
        "Eb8": 4978,
        "E8": 5274,
        "F8": 5588,
        "F#8": 5920,
        "Gb8": 5920,
        "G8": 6272,
        "G#8": 6645,
        "Ab8": 6645,
        "A8": 7040,
        "A#8": 7459,
        "Bb8": 7459,
        "B8": 7902,
        "C9": 8372,
        "C#9": 8870,
        "Db9": 8870,
        "D9": 9397,
        "D#9": 9956,
        "Eb9": 9956,
        "E9": 10548,
        "F9": 11175,
        "F#9": 11840,
        "Gb9": 11840,
        "G9": 12544,
        "G#9": 13290,
        "Ab9": 13290,
        "A9": 14080,
        "A#9": 14917,
        "Bb9": 14917,
        "B9": 15804
    ]
    
    /* Constructor */

    init() {

        BIT_RISE /= SPEED_FACTOR
        BIT_FALL /= SPEED_FACTOR

        LOW_BIT_SUSTAIN /= SPEED_FACTOR
        HIGH_BIT_SUSTAIN /= SPEED_FACTOR
        START_STOP_BIT_SUSTAIN /= SPEED_FACTOR

        NOTE_RISE_DURATION /= SPEED_FACTOR
        NOTE_FALL_DURATION /= SPEED_FACTOR
        NOTE_LONG_FALL_DURATION /= SPEED_FACTOR

    }
    
    /* Encoding constant */

    private let HAMMING_CODE = [
        [0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 0, 0, 0, 0],
        [1, 0, 0, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 0, 0],
        [0, 1, 0, 1, 0, 1, 0],
        [1, 0, 1, 1, 0, 1, 0],
        [1, 1, 0, 0, 1, 1, 0],
        [0, 0, 1, 0, 1, 1, 0],
        [1, 1, 0, 1, 0, 0, 1],
        [0, 0, 1, 1, 0, 0, 1],
        [0, 1, 0, 0, 1, 0, 1],
        [1, 0, 1, 0, 1, 0, 1],
        [1, 0, 0, 0, 0, 1, 1],
        [0, 1, 1, 0, 0, 1, 1],
        [0, 0, 0, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1]
    ]

    /* Data classes */

    private struct State {
        var amplitudePhase: Float = 0.0
        var x: Float = 1.0
        var y: Float = 0.0
    }

    private struct Note {
        var frequency: Int = 256
        var duration: Int = 1
    }

    private struct CRC16 {
        var low: Int = 0
        var high: Int = 0
    }

    /* Functions: calculate CRC code */

    private func updateCRC16(crc: Int, incr: Int) -> Int {

        let CRC_POLY: Int = 0x1021

        let xor: Int = (crc >> 15) & 0xFFFF
        var out: Int = (crc << 1) & 0xFFFF

        if incr > 0 { out += 1 }

        if xor > 0 { out = out ^ CRC_POLY }

        return out

    }

    private func createCRC16(bytes: Array<Int>) -> CRC16 {

        var crc: Int = 0

        bytes.forEach { byte in
            for x in stride(from: 7, through: 0, by: -1) {
                crc = updateCRC16(crc: crc, incr: byte & (1 << x))
            }
        }

        for _ in 0...15 {
            crc = updateCRC16(crc: crc, incr: 0)
        }

        return CRC16(
            low: crc & 0xFF,
            high: (crc >> 8) & 0xFF
        )

    }

    /* Function: encode bytes */

    private func encode(bytes: Array<Int>) -> Array<Int> {

        var bitSequence = Array<Int>()

        bytes.forEach { byte in

            if USE_HAMMING_CODE {

                let low: Int = byte & 0x0F
                let high: Int = (byte & 0xF0) >> 4

                for x in 0..<7 {
                    bitSequence.append(HAMMING_CODE[low][x])
                    bitSequence.append(HAMMING_CODE[high][x])
                }

            } else {

                for x in 0..<8 {

                    let mask = 0x01 << x
                    
                    bitSequence.append(byte & mask == mask ? 1 : 0)

                }

            }

        }

        return bitSequence

    }

    /* Functions: parses notes */

    private func parseNotes(noteArray: Array<String>) -> Array<Note> {

        var notes = Array<Note>()

        noteArray.forEach { note in

            if note.range(of: REGEX, options: .regularExpression) != nil {

                if let frequency = FREQUENCY_LOOKUP[String(note.split(separator: ":")[0])] {

                    let duration = Int(note.split(separator: ":")[1]) ?? 1

                    notes.append(Note(frequency: frequency, duration: duration))

                }

            }

        }

        if notes.count == 0 { notes.append(Note()) }

        return notes

    }

    /* Functions to generate waveforms */

    private func createWaveformComponent( waveform: inout Array<Float>, state: inout State, sampleRate: Int, frequency: Int, phase: Float, rampUp: Float, sustain: Float, rampDown: Float) {

        let samplesInRampUp: Int = Int(round(rampUp * Float(sampleRate)))

        let samplesInSustain: Int = Int(round(sustain * Float(sampleRate)))

        let samplesInRampDown: Int = Int(round(rampDown * Float(sampleRate)))

        let theta: Float = 2.0 * Float.pi * Float(frequency) / Float(sampleRate)

        for k in 0...samplesInRampUp + samplesInSustain + samplesInRampDown {

            if k < samplesInRampUp {
                state.amplitudePhase = min(Float.pi / 2.0, state.amplitudePhase + Float.pi / 2.0 / Float(samplesInRampUp))
            }

            if k >= samplesInRampUp + samplesInSustain {
                state.amplitudePhase = max(0.0,state.amplitudePhase - Float.pi / 2.0 / Float(samplesInRampDown))
            }

            let volume: Float = pow(sin(state.amplitudePhase), 2.0)

            waveform.append(volume * phase * state.x)

            let x: Float = state.x * cos(theta) - state.y * sin(theta)

            let y: Float = state.x * sin(theta) + state.y * cos(theta)

            state.x = x

            state.y = y

        }

    }

    private func createWaveform(sampleRate: Int, duration: Int?, byteArray: Array<Int>?, noteArray: Array<String>) -> Array<Float> {

        var waveform = Array<Float>()

        var waveform1 = Array<Float>()

        var waveform2 = Array<Float>()

        /* Generate note sequence */

        let notes: Array<Note> = parseNotes(noteArray: noteArray)
    
        /* Counters used during sound waveform creation */

        var state: State = State()

        var phase: Float = 1.0
        
        /* Generate data or tone */
        
        if byteArray != nil {
 
            /* Initial start bits */
            
            for _ in 0..<NUMBER_OF_START_BITS {

                createWaveformComponent(waveform: &waveform1, state: &state, sampleRate: sampleRate, frequency: CARRIER_FREQUENCY, phase: phase, rampUp: BIT_RISE, sustain: START_STOP_BIT_SUSTAIN, rampDown: BIT_FALL)

                phase *= -1.0

            }
            
            /* Generate bit sequence */

            let crc: CRC16 = createCRC16(bytes: byteArray!)

            var bytes: Array<Int> = Array<Int>()

            byteArray!.forEach { byte in bytes.append(byte) }

            bytes.append(crc.low)
            bytes.append(crc.high)
        
            let bitSequence: Array<Int> = encode(bytes: bytes)

            /* Display output */

            print("AUDIOMOTH CHIME: " + String(bytes.count) + " bytes")

            print("AUDIOMOTH CHIME: " + String(bitSequence.count) + " bits")

            /* Data bits */

            bitSequence.forEach { byte in

                let duration = byte == 1 ? HIGH_BIT_SUSTAIN : LOW_BIT_SUSTAIN

                createWaveformComponent(waveform: &waveform1, state: &state, sampleRate: sampleRate, frequency: CARRIER_FREQUENCY, phase: phase, rampUp: BIT_RISE, sustain: duration, rampDown: BIT_FALL)

                phase *= -1.0

            }

            /* Stop bits */

            for _ in 0..<NUMBER_OF_STOP_BITS {

                createWaveformComponent(waveform: &waveform1, state: &state, sampleRate: sampleRate, frequency: CARRIER_FREQUENCY, phase: phase, rampUp: BIT_RISE, sustain: START_STOP_BIT_SUSTAIN, rampDown: BIT_FALL)

                phase *= -1.0

            }
            
        } else {

            let tonePairs: Int = Int(floor(Float(max(MIN_TONE_DURATION, min(MAX_TONE_DURATION, duration!))) / 1000.0 / (2 * BIT_RISE + HIGH_BIT_SUSTAIN + LOW_BIT_SUSTAIN + 2 * BIT_FALL)))

            for _ in 0..<tonePairs {

                createWaveformComponent(waveform: &waveform1, state: &state, sampleRate: sampleRate, frequency: CARRIER_FREQUENCY, phase: phase, rampUp: BIT_RISE, sustain: HIGH_BIT_SUSTAIN, rampDown: BIT_FALL)

                phase *= -1.0

                createWaveformComponent(waveform: &waveform1, state: &state, sampleRate: sampleRate, frequency: CARRIER_FREQUENCY, phase: phase, rampUp: BIT_RISE, sustain: LOW_BIT_SUSTAIN, rampDown: BIT_FALL)

                phase *= -1.0

            }
            
            
        }

        /* Reset counter */

        state = State()

        /* Calculate note duration */

        var sumOfDurations: Int = 0

        notes.forEach { note in sumOfDurations += note.duration }

        let noteDuration: Float = (Float(waveform1.count) / Float(sampleRate) - Float(notes.count) * Float(NOTE_RISE_DURATION + NOTE_FALL_DURATION) +  Float(NOTE_FALL_DURATION - NOTE_LONG_FALL_DURATION)) / Float(sumOfDurations)

        /* Create note waveform */

        for (index, note) in notes.enumerated() {

            let noteFallDuration = index == notes.count - 1 ? NOTE_LONG_FALL_DURATION : NOTE_FALL_DURATION

            createWaveformComponent(waveform: &waveform2, state: &state, sampleRate: sampleRate, frequency: note.frequency, phase: 1.0, rampUp: NOTE_RISE_DURATION, sustain:noteDuration * Float(note.duration), rampDown: noteFallDuration)

        }

        /* Sum the waveforms */

        let length = min(waveform1.count, waveform2.count)

        for i in 0..<length { waveform.append(waveform1[i] / 4.0 + waveform2[i] / 2.0) }

        return waveform

    }
    
    /* Function to generate sound */

    func play(sendTime: Date?, duration: Int?, byteArray: Array<Int>?, noteArray: Array<String>) {

        /* Generate waveform */

        let SAMPLE_RATE: Int = 44100

        let waveform: Array<Float> = createWaveform(sampleRate: SAMPLE_RATE, duration: duration, byteArray: byteArray, noteArray: noteArray)
        
        /* Make the WAV header */
        
        let HEADER_SIZE: Int = 44
        
        let BYTES_PER_SAMPLE: Int = 2
        
        let BYTES_IN_UINT32_VALUE: Int = 4
        
        data = Data(count: HEADER_SIZE + BYTES_PER_SAMPLE * waveform.count)

        func writeUInt32ToData(index: Int, value: UInt32) {
            
            data[index] = UInt8(value & 0xFF)
            data[index + 1] = UInt8((value >> 8) & 0xFF)
            data[index + 2] = UInt8((value >> 16) & 0xFF)
            data[index + 4] = UInt8((value >> 24) & 0xFF)
            
        }
        
        for i in 0..<4 { data[i] = String("RIFF").utf8.map{ UInt8($0) }[i] }
        
        let riffChunkSize: UInt32 = UInt32(data.count - 4 - BYTES_IN_UINT32_VALUE)
        
        writeUInt32ToData(index: 4, value: riffChunkSize)
        
        for i in 0..<8 { data[8 + i] = String("WAVEfmt ").utf8.map{ UInt8($0) }[i] }
        
        data[16] = 16  // Format chunk size
        
        data[20] = 1   // PCM
        
        data[22] = 1   // Number of channels
        
        let sampleRate: UInt32 = UInt32(SAMPLE_RATE)
        
        writeUInt32ToData(index: 24, value: sampleRate)
        
        let bytesPerSecond: UInt32 = UInt32(data.count - 4 - BYTES_IN_UINT32_VALUE)
        
        writeUInt32ToData(index: 28, value: bytesPerSecond)

        data[32] = 2   // Bytes per capture
        
        data[34] = 16  // Bits per sample
        
        for i in 0..<4 { data[36 + i] = String("data").utf8.map{ UInt8($0) }[i] }
        
        let dataChunkSize: UInt32 = UInt32(BYTES_PER_SAMPLE * waveform.count)
        
        writeUInt32ToData(index: 40, value: dataChunkSize)
        
        /* Convert the waveform data */
        
        var index: Int = HEADER_SIZE
        
        waveform.forEach { sample in
            
            let value: Int16 = Int16(sample * Float(Int16.max))
            
            data[index] = UInt8(value & 0xFF)
            data[index+1] = UInt8((value >> 8) & 0xFF)
            
            index += 2
        
        }
        
        /* Play the waveform at the appropriate time */
        
        do {
            
            /* Initialise the audio player */
            
            audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: "wav")
            
            audioPlayer.prepareToPlay()
            
            /* Wait for the correct play time */
            
            if (sendTime != nil) {
                
                var now = Date()
                
                if (now < sendTime!) {
                    
                    let delay = sendTime!.timeIntervalSince(now) * 1000
                    
                    print("AUDIOMOTH CHIME: Waiting " + String(format: "%0.0f", delay) + " milliseconds")
                    
                    while (now < sendTime!) {
                        
                        now = Date()
                        
                    }
                    
                }
                
            }
            
            /* Play the audio */
            
            print("AUDIOMOTH CHIME: Start")
            
            audioPlayer.play()
            
            while (audioPlayer.isPlaying ) { }
            
            print("AUDIOMOTH CHIME: Done")
            
        } catch {
            
            print(error)
            
        }

    }

    /* Public chime function */

    func tone(duration: Int, noteArray: Array<String>) {

        play(sendTime: nil, duration: duration, byteArray: nil, noteArray: noteArray)

    }

    func chime(sendTime: Date?, byteArray: Array<Int>, noteArray: Array<String>) {
        
        play(sendTime: sendTime, duration: nil, byteArray: byteArray, noteArray: noteArray)

    }

}
