faceDetect
==========

phonegap plugin to detect faces on pictures

sample phonegap project with the face detect iOS plugin.

if it detects faces return an array with the faces.
Each face have the face rectangle and the eyes and mouth points (see the index.html example for more info)

The face is a rectangle or square whit this format {{x,y},{widht,height}} (default rectangle to string conversion, contact me if you want another format)
The eyes and mouth poinths have this format {x,y} (default point to string conversion, contact me if you want another format)

x is the x coordinate on the original image
y is the y coordinate on the original image
width is the width of the face on the original image
height is the height of the face on the original image
As I've said, the sizes and points are for the original image, if you resize the image you have to recalculate the coordinates for your size.

if it doesn't detect a face it retunr 'No faces.'

The sample project uses the camera sample code
It uses the camera function with destinationType.FILE_URI (IMPORTANT!!!)

Steps to use in your own project:
1.- You have to include the QuarzCore and CoreImage frameworks to your project
2.- Put this line in your plugins section inside config.xml <plugin name="FaceDetect" value="FaceDetect" />
3.- Drag FaceDetec.h and FaceDetect.m to your project
4.- Put the FaceDetect.js inside your www folder and link it in your index.html
