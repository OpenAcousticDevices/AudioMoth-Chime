/****************************************************************************
* AudioMothChimeConnector.swift
* openacousticdevices.info
* June 2020
*****************************************************************************/

import Foundation

class AudioMothChimeConnector {

    /* Useful constants */

    private let BITS_PER_BYTE: Int = 8
    private let BITS_IN_INT16: Int = 16
    private let BITS_IN_INT32: Int = 32

    private let LENGTH_OF_CHIME_PACKET: Int = 6
    private let LENGTH_OF_DEPLOYMENT_ID: Int = 8

    private let MILLISECONDS_IN_SECOND = 1000
    private let SECONDS_IN_MINUTE = 60

    /* AudioMothChime object */

    private let audioMothChime = AudioMothChime()

    /* Private functions to set data */

    private func setBit(data: inout Array<Int>, index: inout Int, value: Bool) {

        let byte = index / BITS_PER_BYTE
        let bit = index % BITS_PER_BYTE

        if (value) {

            data[byte] = data[byte] | (1 << bit)

        }

        index += 1

    }

    private func setBits(data: inout Array<Int>, index: inout Int, value: Int, length: Int) {

        for i in 0..<length {

            let mask = 1 << i

            setBit(data: &data, index: &index, value: value & mask == mask)

        }

    }

    private func setTimeData(data: inout Array<Int>, index: inout Int, date: Date, timezone: TimeZone) {

        /* Calculate timestamp and offset */

        let timestamp: Int = Int(date.timeIntervalSince1970)

        let timezoneMinutes: Int = timezone.secondsFromGMT() / SECONDS_IN_MINUTE
        
        /* Time and timezone */

        setBits(data: &data, index: &index, value: timestamp, length: BITS_IN_INT32)

        setBits(data: &data, index: &index, value: timezoneMinutes, length: BITS_IN_INT16)

    }

    /* Public interface function */

    func playTime(date: Date, timezone: TimeZone) {

        /* Set up array */

        var index: Int = 0

        var data = Array<Int>(repeating: 0, count: LENGTH_OF_CHIME_PACKET)

        /* Set the time date */

        setTimeData(data: &data, index: &index, date: date, timezone: timezone)

        /* Play the data */

        audioMothChime.chime(byteArray: data, noteArray: ["C5:1", "D5:1", "E5:1", "C5:3"])

    }

    func playTimeAndDeploymentID(date: Date, timezone: TimeZone, deploymentID: Array<Int>) {

        /* Check deployment ID length */

        if deploymentID.count != LENGTH_OF_DEPLOYMENT_ID {
            
            print("AUDIOMOTHCHIME_CONNECTOR: Deployment ID is incorrect length")

            return
            
        }
        
        /* Set up array */

        var index: Int = 0

        var data: Array<Int> = Array<Int>(repeating: 0, count: LENGTH_OF_CHIME_PACKET + LENGTH_OF_DEPLOYMENT_ID)

        /* Set the time date */

        setTimeData(data: &data, index: &index, date: date, timezone: timezone)

        /* Set the deployment ID */

        let length = LENGTH_OF_CHIME_PACKET + LENGTH_OF_DEPLOYMENT_ID

        for i in 0..<LENGTH_OF_DEPLOYMENT_ID {

            data[length - 1 - i] = deploymentID[i] & 0xFF

        }

        /* Play the data */

        audioMothChime.chime(byteArray: data, noteArray: ["Eb5:1", "G5:1", "D5:1", "F#5:1", "Db5:1", "F5:1", "C5:1", "E5:5"])

    }

}
