import 'package:flutter/material.dart';
import 'package:simple_camera/simple_camera.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Simple Camera',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Simple Camera Example'),
    );
  }
}

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
