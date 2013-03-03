faceDetect
==========

phonegap plugin to detect faces on pictures

sample phonegap project with the face detect iOS plugin.

if it detects faces return a string with this format {{x1,y1},{widht1,height1}}{{x2,y2}{width2,height2}...{{xn,yn},{widthn,heightn}}
if it doesn't detect a face alerts 'No faces.'

The sample project uses the camera sample code
It uses the camera function with destinationType.FILE_URI (IMPORTANT!!!)
