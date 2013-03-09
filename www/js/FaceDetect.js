window.FaceDetect = function(str, callback, errCallback) {
    cordova.exec(callback, errCallback, "FaceDetect", "detect", [str]);
};