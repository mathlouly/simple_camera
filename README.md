# Simple Camera

[![simple camera package](https://img.shields.io/badge/simple__camera-v1.0.2-green)](https://github.com/mathlouly/simple_camera)

It is a package for using the camera in a simple and fast way.

## Notes Version 1.0.3

* Fix camera erro when dispose
* Fix camera preview distortion
* Fix camera switch
* Fix camera switch
* Add logger all functions
* Upgrage SDK version 2 to 3
* New features camera preview
  - Video recording
  - Switch flash
  - Camera image full or 1:1

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
  simple_camera: ^1.0.3
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

  @override
  void dispose() {
    super.dispose();
    simpleCamera.dispose();
  }

  void initSimpleCamera() async {
    try {
      // Here you initialize the camera and pass some options, such as resolution, image format, etc..
      // If it does not inform any camera description, by default it starts with the front camera
      // To learn more, see the documentation.
      simpleCamera.initializeCamera().then((value) {
        setState(() {});
      });
    } catch (e) {
      // Important
      // Here you must give the permissions to access the device camera and or audio
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleCameraPreview(
        simpleCamera: simpleCamera,
        isFull: true,
        onPressedGallery: () {},
        onPressedVideoRecording: (xfile) {
          if (kDebugMode) {
            print(xfile?.name);
          }
        },
        onPressedTakePicture: (xfile) {
          if (kDebugMode) {
            print(xfile?.name);
          }
        },
      ),
    );
  }
}

```

## References and description

Here are all the references you can use and what each one does

| Name                  | Return                          | Description                                                           |
|-----------------------|---------------------------------|-----------------------------------------------------------------------|
| availableCameras      | List<CameraDescription>         | returns all available cameras on the device                           |
| initializeCamera      | void                            | initialize the camera                                                 |
| switchCamera          | void                            | switch between back and front camera                                  |
| switchFlash           | void                            | switch between flash modes                                             |
| startVideoStream      | Stream<CameraImageData>         | starts a stream of images from the video                              |
| stopVideoStream       | void                            | close the video stream                                                |
| startVideoRecording   | void                            | starts recording a video                                              |
| stopVideoRecording    | Future<XFile>                   | finishes recording and returns the file                                 |
| startImageStream      | Stream<CameraImageData>         | returns an image stream                                               |
| setFlashMode          | void                            | change flash mode                                                      |
| setExposureMode       | void                            | change the exposure mode                                              |
| setFocusMode          | void                            | change focus mode                                                     |
| buildPreview          | Widget                          | returns a widget for the camera view                                  |
| dispose               | void                            | discard the camera                                                    |
|-----------------------|---------------------------------|-----------------------------------------------------------------------|