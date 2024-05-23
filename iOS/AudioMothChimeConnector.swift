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

    private let BITS_IN_LATITUDE_AND_LONGITUDE: Int = 28
    
    private let LATITUDE_PRECISION: Double = 1000000.0
    private let LONGITUDE_PRECISION: Double = 500000.0
    
    private let LENGTH_OF_TIME: Int = 6
    private let LENGTH_OF_LOCATION: Int = 7
    private let LENGTH_OF_DEPLOYMENT_ID: Int = 8

    private let MILLISECONDS_IN_SECOND = 1000
    private let SECONDS_IN_MINUTE = 60
    private let MINIMUM_DELAY = 0.200
    private let ACOUSTIC_LAG = 0.080
    
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

    private func encodeTime(data: inout Array<Int>, index: inout Int, date: Date, timezone: TimeZone) {

        /* Calculate timestamp and offset */

        let timestamp: Int = Int(date.timeIntervalSince1970 + 0.5)

        let timezoneMinutes: Int = timezone.secondsFromGMT() / SECONDS_IN_MINUTE
        
        /* Time and timezone */

        setBits(data: &data, index: &index, value: timestamp, length: BITS_IN_INT32)

        setBits(data: &data, index: &index, value: timezoneMinutes, length: BITS_IN_INT16)

    }
    
    private func encodeLocation(data: inout Array<Int>, index: inout Int, latitude: Double, longitude: Double) {
            
        let intLatitude = Int(round(max(-90.0, min(90.0, latitude)) * LATITUDE_PRECISION))
        
        let intLongitude = Int(round(max(-180.0, min(180.0, longitude)) * LONGITUDE_PRECISION))
        
        setBits(data: &data, index: &index, value: intLatitude, length: BITS_IN_LATITUDE_AND_LONGITUDE)
        
        setBits(data: &data, index: &index, value: intLongitude, length: BITS_IN_LATITUDE_AND_LONGITUDE)
        
    }
    
    private func encodeDeploymentID(data: inout Array<Int>, index: inout Int, deploymentID: Array<Int>) {
        
        for i in 0..<LENGTH_OF_DEPLOYMENT_ID {

            data[index / BITS_PER_BYTE] = deploymentID[LENGTH_OF_DEPLOYMENT_ID - 1 - i] & 0xFF
            
            index += BITS_PER_BYTE

        }
        
    }

    /* Public interface functions */
    
    func playTone(duration: Int) {
        
        audioMothChime.tone(duration: duration, noteArray: ["C5:1"])

    }

    func playTime(date: Date, timezone: TimeZone, latitude: Double?, longitude: Double?) {

        /* Set up array */

        var index: Int = 0
        
        let locationValid = latitude != nil && longitude != nil
        
        let length: Int = LENGTH_OF_TIME + (locationValid ? LENGTH_OF_LOCATION : 0)

        var data = Array<Int>(repeating: 0, count: length)

        /* Set the time date */
        
        var delay = 1.0 - date.timeIntervalSince1970.truncatingRemainder(dividingBy: 1) - ACOUSTIC_LAG
        
        if delay < MINIMUM_DELAY { delay += 1.0 }
        
        let sendTime = date.addingTimeInterval(delay)
        
        encodeTime(data: &data, index: &index, date: sendTime, timezone: timezone)
        
        if locationValid { encodeLocation(data: &data, index: &index, latitude: latitude!, longitude: longitude!) }

        /* Play the data */
        
        var tune = ["C5:1", "D5:1", "E5:1", "C5:3"]
        
        if locationValid { tune += ["D5:1", "E5:1", "C5:3"] }

        audioMothChime.chime(sendTime: sendTime, byteArray: data, noteArray: tune)

    }

    func playTimeAndDeploymentID(date: Date, timezone: TimeZone, latitude: Double?, longitude: Double?, deploymentID: Array<Int>) {

        /* Check deployment ID length */

        if deploymentID.count != LENGTH_OF_DEPLOYMENT_ID {
            
            print("AUDIOMOTH CHIME CONNECTOR: Deployment ID is incorrect length")

            return
            
        }
        
        /* Set up array */

        var index: Int = 0
        
        let locationValid = latitude != nil && longitude != nil
        
        let length: Int = LENGTH_OF_TIME + (locationValid ? LENGTH_OF_LOCATION : 0) + LENGTH_OF_DEPLOYMENT_ID

        var data: Array<Int> = Array<Int>(repeating: 0, count: length)

        /* Set the time date */
        
        var delay = 1.0 - date.timeIntervalSince1970.truncatingRemainder(dividingBy: 1) - ACOUSTIC_LAG
        
        if delay < MINIMUM_DELAY { delay += 1.0 }
        
        let sendTime = date.addingTimeInterval(delay)

        encodeTime(data: &data, index: &index, date: sendTime, timezone: timezone)
        
        if locationValid { encodeLocation(data: &data, index: &index, latitude: latitude!, longitude: longitude!) }

        encodeDeploymentID(data: &data, index: &index, deploymentID: deploymentID)

        /* Play the data */
        
        var tune = ["Eb5:1", "G5:1", "D5:1", "F#5:1", "Db5:1", "F5:1", "C5:1", "E5:5"]
        
        if locationValid { tune += ["Db5:1", "F5:1", "C5:1", "E5:4"] }

        audioMothChime.chime(sendTime: sendTime, byteArray: data, noteArray: tune)

    }

}
