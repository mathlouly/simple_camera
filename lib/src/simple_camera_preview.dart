// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_camera/src/model/simple_camera_action_option.dart';
import 'package:simple_camera/src/simple_camera.dart';

class SimpleCameraPreview extends StatefulWidget {
  const SimpleCameraPreview({
    super.key,
    required this.simpleCamera,
    this.photoTextOption,
    this.videoTextOption,
    this.isFull = false,
    this.onPressedGallery,
    this.onPressedTakePicture,
    this.onPressedVideoRecording,
  });

  final SimpleCamera simpleCamera;
  final String? photoTextOption;
  final String? videoTextOption;
  final bool isFull;
  final VoidCallback? onPressedGallery;
  final ValueChanged<XFile?>? onPressedTakePicture;
  final ValueChanged<XFile?>? onPressedVideoRecording;

  @override
  State<SimpleCameraPreview> createState() => _SimpleCameraPreviewState();
}

class _SimpleCameraPreviewState extends State<SimpleCameraPreview> {
  var simpleCameraActionOption = SimpleCameraActionOption.photo;
  String? timerVideoRecording;

  Widget _stadiumButton({
    required IconData icon,
    VoidCallback? onPressed,
    bool filled = false,
    Color colorFilled = Colors.white,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: filled ? colorFilled : Colors.black.withOpacity(0.5),
        shape: const StadiumBorder(
          side: BorderSide(color: Colors.white),
        ),
        padding: const EdgeInsets.all(0),
      ),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Icon(
          icon,
          size: 18,
          color: filled ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget _circleButton({IconData? icon, VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.5),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(0),
      ),
      child: SizedBox(
        width: 50,
        height: 50,
        child: icon != null
            ? Icon(
                icon,
                size: 24,
                color: Colors.white,
              )
            : null,
      ),
    );
  }

  Widget _takePictureButton() {
    return OutlinedButton(
      onPressed: () async {
        HapticFeedback.vibrate();
        var file = await widget.simpleCamera.takePicture();
        widget.onPressedTakePicture!(file);
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(0),
      ),
      child: const SizedBox(
        width: 70,
        height: 70,
      ),
    );
  }

  Widget _videoButton() {
    return OutlinedButton(
      onPressed: () async {
        if (!widget.simpleCamera.isRecordingVideo) {
          HapticFeedback.vibrate();
          await widget.simpleCamera.startVideoRecording();
          initTimerVideoRecording();
        } else {
          HapticFeedback.vibrate();
          var file = await widget.simpleCamera.stopVideoRecording();
          widget.onPressedVideoRecording!(file);
        }
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.red[400],
        shape: const CircleBorder(
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.all(0),
      ),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Icon(
          widget.simpleCamera.isRecordingVideo ? Icons.square : Icons.videocam,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buttonChoseCameraOption({required String text, bool selected = false, VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Colors.white38 : Colors.black.withOpacity(0.5),
        shape: const StadiumBorder(
          side: BorderSide(color: Colors.white),
        ),
        padding: const EdgeInsets.all(0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  IconData _switchIconFlash(FlashMode flash) {
    switch (flash) {
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.torch:
        return Icons.flashlight_on;
      default:
        return Icons.flash_off;
    }
  }

  void changeCameraOption(SimpleCameraActionOption action) {
    if (!widget.simpleCamera.isRecordingVideo) {
      setState(() {
        simpleCameraActionOption = action;
      });
    }
  }

  void initTimerVideoRecording() {
    int seconds = 0;
    int minutes = 0;
    int hours = 0;
    setState(() {
      timerVideoRecording = '00:00:00';
    });
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 60) {
        seconds = 0;
        minutes++;
      }
      if (minutes == 60) {
        minutes = 0;
        hours++;
      }
      seconds++;

      final secondsStr = seconds.toString().padLeft(2, '0');
      final minutesStr = minutes.toString().padLeft(2, '0');
      final hoursStr = hours.toString().padLeft(2, '0');
      setState(() {
        timerVideoRecording = '$hoursStr:$minutesStr:$secondsStr';
      });
      if (!widget.simpleCamera.isRecordingVideo) {
        setState(() {
          timerVideoRecording = null;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget cameraBuilder(bool isExpanded) {
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: FittedBox(
                fit: isExpanded ? BoxFit.cover : BoxFit.fitWidth,
                child: SizedBox(
                  width: widget.simpleCamera.previewHeight,
                  height: widget.simpleCamera.previewWidth,
                  child: widget.simpleCamera.buildPreview(),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 16),
                        _stadiumButton(
                          icon: _switchIconFlash(widget.simpleCamera.flashMode),
                          filled: widget.simpleCamera.flashMode == FlashMode.always ||
                              widget.simpleCamera.flashMode == FlashMode.auto ||
                              widget.simpleCamera.flashMode == FlashMode.torch,
                          colorFilled: widget.simpleCamera.flashMode == FlashMode.torch ? Colors.yellow : Colors.white,
                          onPressed: () {
                            widget.simpleCamera.switchFlash();
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        if (widget.onPressedVideoRecording != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buttonChoseCameraOption(
                                text: widget.photoTextOption ?? 'Photo',
                                selected: SimpleCameraActionOption.photo == simpleCameraActionOption,
                                onPressed: () => changeCameraOption(SimpleCameraActionOption.photo),
                              ),
                              const SizedBox(width: 16),
                              _buttonChoseCameraOption(
                                text: widget.videoTextOption ?? 'Video',
                                selected: SimpleCameraActionOption.video == simpleCameraActionOption,
                                onPressed: () => changeCameraOption(SimpleCameraActionOption.video),
                              ),
                            ],
                          ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.onPressedGallery != null)
                              _circleButton(
                                icon: Icons.photo,
                                onPressed: widget.onPressedGallery,
                              )
                            else
                              _circleButton(),
                            if (SimpleCameraActionOption.photo == simpleCameraActionOption)
                              _takePictureButton()
                            else
                              _videoButton(),
                            _circleButton(
                              icon: Icons.cameraswitch,
                              onPressed: () => widget.simpleCamera.switchCamera(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (timerVideoRecording != null)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          timerVideoRecording!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return widget.simpleCamera.isInitialized
        ? ValueListenableBuilder<SimpleCameraValue>(
            valueListenable: widget.simpleCamera,
            builder: (context, value, child) {
              return cameraBuilder(widget.isFull);
            },
          )
        : Container(
            color: Colors.black,
          );
  }
}
