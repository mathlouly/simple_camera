# Simple Camera

[![pub package](https://img.shields.io/pub/v/camera.svg)](https://github.com/mathlouly/simple_camera)

It is a package for using the camera in a simple and fast way.

## Features

* Display live camera preview in a widget.
* Access the image and video stream.
* Enable or disable Audio.
* Change resolution image.
* Change format image.
* Change flash mode.
* Change exposure mode.
* Change focus mode.

## Installation and usage

### Add the package to your dependencies

```yaml
dependencies:
  simple_camera: ^1.0.0
  ...
```

### Plataform specific setup

- **iOS**

Add two rows to the `ios/Runner/Info.plist`:

* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

If editing `Info.plist` as text, add:

```xml
<key>NSCameraUsageDescription</key>
<string>your usage description here</string>
<key>NSMicrophoneUsageDescription</key>
<string>your usage description here</string>
```

- **Android**

Change the minimum SDK version to 21 (or higher) in `android/app/build.gradle`:

```
minSdkVersion 21
```

If you want to record videos with audio, add this permission to your `AndroidManifest.xml`:

## Getting started

To begin with, it's very simple, just import and instantiate SimpleCamera and then initialize it according to the example, after that you can use SimpleCameraPreview or create your own screen by calling simpleCamera.buildPreview()

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var simpleCamera = SimpleCamera();

  @override
  void initState() {
    super.initState();
    initSimpleCamera();
  }

  void initSimpleCamera() async {
    try {
      // Here you initialize the camera and pass some options, such as resolution, image format, etc..
      // If it does not inform any camera description, by default it starts with the front camera
      // To learn more, see the documentation.
      simpleCamera.initializeCamera();
    } catch (e) {
      // Important
      // Here you must give the permissions to access the device camera and or audio
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // Simple camera has a preview to view the camera image,
        //if you have questions about how it works, see the package example
        child: SimpleCameraPreview(
          simpleCamera: simpleCamera,
          onPressedTakePicture: (xfile) {
            // ignore: avoid_print
            print(xfile.name);
          },
        ),
      ),
    );
  }
}
```

## References and description

Here are all the references you can use and what each one does

| Name                  | Return                    | Description                                                                 |
|-----------------------|-------------------------|-------------------------------------------------------------------------------|
| availableCameras      | List<CameraDescription>         | returns all available cameras on the device                           |
| initializeCamera      | void                            | initialize the camera                                                 |
| switchCamera          | void                            | switch between back and front camera                                  |
| toggleFlash           | void                            | toggles between flash on and off                                      |
| startVideoStream      | Stream<CameraImageData>         | starts a stream of images from the video                              |
| stopVideoStream       | void                            | close the video stream                                                |
| startVideoRecording   | void                            | starts recording a video                                              |
| stopVideoRecording    | Future<XFile>                   | finishes recording and returns the file                               |
| startImageStream      | Stream<CameraImageData>         | returns an image stream                                               |
| setFlashMode          | void                            | change flash mode                                                     |
| setExposureMode       | void                            | change the exposure mode                                              |
| setFocusMode          | void                            | change focus mode                                                     |
| buildPreview          | Widget                          | returns a widget for the camera view                                  |
| dispose               | void                            | discard the camera                                                    |
