/* global cordova */

var exec = require('cordova/exec');

var MediaPermissions = {

    check: function () {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, 'MediaPermissions', 'check', []);
        });
    },

    request: function () {
        return new Promise(function (resolve, reject) {
            exec(resolve, reject, 'MediaPermissions', 'request', []);
        });
    },
};

module.exports = MediaPermissions;
