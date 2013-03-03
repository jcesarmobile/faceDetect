window.FaceDetect = function(str, callback) {
    cordova.exec(callback, function(err) {
                 callback('No faces.');
                 }, "FaceDetect", "detect", [str]);
};