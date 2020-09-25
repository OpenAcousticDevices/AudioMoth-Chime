/****************************************************************************
 * audiomothchime_connector.js
 * openacousticdevices.info
 * August 2020
 *****************************************************************************/

'use strict';

/* global AudioMothChime */
/* jslint bitwise: true */

var AudioMothChimeConnector = function () {

    var obj, audioMothChime, LENGTH_OF_DEPLOYMENT_ID;

    LENGTH_OF_DEPLOYMENT_ID = 8;

    /* Function to encode little-endian value */

    function littleEndianBytes (byteCount, value) {

        var i, buffer;

        buffer = [];

        for (i = 0; i < byteCount; i += 1) {

            buffer.push((value >> (i * 8)) & 255);

        }

        return buffer;

    }

    /* Function to generate time data */

    function setTimeData (date) {

        var bytes, unixTime, timezoneMinutes;

        unixTime = Math.round(date.valueOf() / 1000);

        timezoneMinutes = -date.getTimezoneOffset();

        bytes = littleEndianBytes(4, unixTime);

        bytes = bytes.concat(littleEndianBytes(2, timezoneMinutes));

        return bytes;

    }

    /* Main code entry point */

    audioMothChime = new AudioMothChime();

    obj = { };

    obj.playTime = function (date, callback) {

        var bytes = setTimeData(date);

        audioMothChime.chime(bytes, ['C5:1', 'D5:1', 'E5:1', 'C5:3'], callback);

    };

    obj.playTimeAndDeploymentID = function (date, deploymentID, callback) {

        var i, bytes;

        bytes = setTimeData(date);

        if (!deploymentID || deploymentID.length !== LENGTH_OF_DEPLOYMENT_ID) {

            console.log('AUDIOMOTHCHIME_CONNECTOR: Deployment ID is incorrect length');

            return;

        }

        for (i = 0; i < LENGTH_OF_DEPLOYMENT_ID; i += 1) {

            bytes.push(deploymentID[deploymentID.length - 1 - i] & 0xFF);

        }

        audioMothChime.chime(bytes, ['Eb5:1', 'G5:1', 'D5:1', 'F#5:1', 'Db5:1', 'F5:1', 'C5:1', 'E5:5'], callback);

    };

    return obj;

};
