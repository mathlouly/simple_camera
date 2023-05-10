// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:simple_camera/simple_camera.dart';

class SimpleCameraPreview extends StatelessWidget {
  const SimpleCameraPreview({
    Key? key,
    required this.simpleCamera,
    this.isExpanded = false,
    this.onPressedGallery,
    this.onPressedTakePicture,
  }) : super(key: key);

  final SimpleCamera simpleCamera;
  final bool isExpanded;
  final VoidCallback? onPressedGallery;
  final ValueChanged<XFile>? onPressedTakePicture;

  Widget _optionButton({required IconData icon, VoidCallback? onPressed}) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _takePictureButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          width: 4,
          color: Colors.white,
        ),
      ),
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Material(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              var file = await simpleCamera.takePicture();
              onPressedTakePicture!(file);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget cameraBuilder() {
      return Stack(
        fit: StackFit.expand,
        children: [
          simpleCamera.buildPreview(),
          if (!kIsWeb)
            Positioned(
              top: 16,
              right: 16,
              child: _optionButton(
                icon: simpleCamera.flashMode == FlashMode.always
                    ? Icons.flash_on
                    : Icons.flash_off,
                onPressed: () {
                  simpleCamera.toggleFlash();
                },
              ),
            ),
          if (!kIsWeb)
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 100,
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _optionButton(
                          icon: Icons.photo,
                          onPressed: onPressedGallery,
                        ),
                        _takePictureButton(),
                        _optionButton(
                          icon: Icons.cameraswitch,
                          onPressed: () => simpleCamera.switchCamera(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    return simpleCamera.isInitialized
        ? ValueListenableBuilder<SimpleCameraValue>(
            valueListenable: simpleCamera,
            builder: (context, value, child) {
              return isExpanded
                  ? AspectRatio(
                      aspectRatio: simpleCamera.aspectRatio,
                      child: cameraBuilder(),
                    )
                  : cameraBuilder();
            },
          )
        : const SizedBox();
  }
}
