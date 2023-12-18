library simple_camera;

import 'dart:async';

import 'package:camera_android/camera_android.dart';
import 'package:camera_avfoundation/camera_avfoundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_camera/src/simple_camera_logger.dart';

class SimpleCameraValue {
  const SimpleCameraValue({
    required this.isInitialized,
    required this.previewWidth,
    required this.previewHeight,
    required this.flashMode,
    required this.exposureMode,
    required this.exposurePointSupported,
    required this.focusMode,
    required this.focusPointSupported,
    required this.isTakingPicture,
    required this.isRecordingVideo,
    required this.isStreamingVideo,
    required this.isStreamingImage,
    required this.isDisposed,
    required this.debugLogger,
  });

  const SimpleCameraValue.uninitialized()
      : this(
          isInitialized: false,
          previewWidth: 0,
          previewHeight: 0,
          flashMode: FlashMode.off,
          exposureMode: ExposureMode.auto,
          exposurePointSupported: false,
          focusMode: FocusMode.auto,
          focusPointSupported: false,
          isTakingPicture: false,
          isRecordingVideo: false,
          isStreamingVideo: false,
          isStreamingImage: false,
          isDisposed: false,
          debugLogger: true,
        );

  final bool isInitialized;

  final double previewWidth;

  final double previewHeight;

  final FlashMode flashMode;

  final ExposureMode exposureMode;

  final bool exposurePointSupported;

  final FocusMode focusMode;

  final bool focusPointSupported;

  final bool isTakingPicture;

  final bool isRecordingVideo;

  final bool isStreamingVideo;

  final bool isStreamingImage;

  final bool isDisposed;

  final bool debugLogger;

  SimpleCameraValue copyWith({
    bool? isInitialized,
    double? previewWidth,
    double? previewHeight,
    FlashMode? flashMode,
    ExposureMode? exposureMode,
    bool? exposurePointSupported,
    FocusMode? focusMode,
    bool? focusPointSupported,
    bool? isTakingPicture,
    bool? isRecordingVideo,
    bool? isStreamingVideo,
    bool? isStreamingImage,
    bool? isDisposed,
    bool? debugLogger,
  }) {
    return SimpleCameraValue(
      isInitialized: isInitialized ?? this.isInitialized,
      previewWidth: previewWidth ?? this.previewWidth,
      previewHeight: previewHeight ?? this.previewHeight,
      flashMode: flashMode ?? this.flashMode,
      exposureMode: exposureMode ?? this.exposureMode,
      exposurePointSupported: exposurePointSupported ?? this.exposurePointSupported,
      focusMode: focusMode ?? this.focusMode,
      focusPointSupported: focusPointSupported ?? this.focusPointSupported,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      isStreamingVideo: isStreamingVideo ?? this.isStreamingVideo,
      isStreamingImage: isStreamingImage ?? this.isStreamingImage,
      isDisposed: isDisposed ?? this.isDisposed,
      debugLogger: debugLogger ?? this.debugLogger,
    );
  }

  @override
  String toString() {
    return 'SimpleCameraValue(previewWidth: $previewWidth, previewHeight: $previewHeight, exposureMode: $exposureMode, exposurePointSupported: $exposurePointSupported, focusMode: $focusMode, focusPointSupported: $focusPointSupported, isRecordingVideo: $isRecordingVideo, isStreamingVideo: $isStreamingVideo, isStreamingImage: $isStreamingImage)';
  }
}

class SimpleCameraOptions {
  const SimpleCameraOptions({
    this.resolutionPreset,
    this.imageFormatGroup,
    this.enableAudio,
    this.flashMode,
    this.exposureMode,
    this.focusMode,
  });

  final ResolutionPreset? resolutionPreset;

  final ImageFormatGroup? imageFormatGroup;

  final bool? enableAudio;

  final FlashMode? flashMode;

  final ExposureMode? exposureMode;

  final FocusMode? focusMode;
}

class SimpleCamera extends ValueNotifier<SimpleCameraValue> {
  late CameraPlatform _cameraPlatform;
  CameraDescription? _description;
  SimpleCameraOptions? _cameraOptions;

  SimpleCamera() : super(const SimpleCameraValue.uninitialized()) {
    _initializePlatform();
  }

  // id of a camera that has not yet been initialized
  static const int kUninitializedCameraId = -1;
  int _cameraId = kUninitializedCameraId;

  /// Receive data from VideoCaptureOptions
  late StreamController<CameraImageData> _videoStream;

  int? get sensorOrientation => _description?.sensorOrientation;

  int get cameraId => _cameraId;

  bool get isInitialized => value.isInitialized;

  bool get isDisposed => value.isDisposed;

  double get previewWidth => value.previewWidth;

  double get previewHeight => value.previewHeight;

  bool get isRecordingVideo => value.isRecordingVideo;

  FlashMode get flashMode => value.flashMode;

  FocusMode get focusMode => value.focusMode;

  ExposureMode get exposureMode => value.exposureMode;

  double get aspectRatio => value.previewHeight / value.previewWidth;

  /// It is defined which platform the camera is on, Android or IOS.
  ///
  /// Coming soon to the web
  ///
  /// Returns [CameraException] if being used on an unsupported platform
  Future<void> _initializePlatform() async {
    if (kIsWeb) {
      _cameraPlatform = CameraPlatform.instance;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          {
            _cameraPlatform = AndroidCamera();
          }
          break;

        case TargetPlatform.iOS:
          {
            _cameraPlatform = AVFoundationCamera();
          }
          break;

        default:
          {
            throw CameraException(
              "Platform not found or not supported",
              "See the documentation",
            );
          }
      }
    }
  }

  /// Returns all available cameras
  ///
  /// By default 0 is always the back camera and 1 is always the front camera,
  /// the other options are other cameras if the device has more than 2 cameras
  Future<List<CameraDescription>> availableCameras() async {
    try {
      return await _cameraPlatform.availableCameras();
    } on CameraException catch (e) {
      throw CameraException(e.code, e.description);
    }
  }

  /// Initializes the camera on the device.
  ///
  /// Throws a [CameraException] if the initialization fails.
  Future<void> initializeCamera({
    CameraDescription? cameraDescription,
    SimpleCameraOptions? options,
  }) async {
    final cameras = await _cameraPlatform.availableCameras();

    if (cameras.isEmpty) {
      if (value.debugLogger) {
        SimpleCameraLogger.w("[Simple Camera] Camera is empty");
      }
      throw CameraException(
        "Available Cameras is Empty",
        "Connect some camera",
      );
    }

    _description = cameraDescription ?? cameras.first;

    try {
      final Completer<CameraInitializedEvent> initializeCompleter = Completer<CameraInitializedEvent>();

      _cameraId = await _cameraPlatform.createCamera(
        _description!,
        options?.resolutionPreset ?? ResolutionPreset.medium,
        enableAudio: options?.enableAudio ?? false,
      );

      _cameraPlatform.onCameraInitialized(_cameraId).first.then(
        (CameraInitializedEvent event) {
          initializeCompleter.complete(event);
        },
      );

      await _cameraPlatform.initializeCamera(
        _cameraId,
        imageFormatGroup: options?.imageFormatGroup ?? ImageFormatGroup.jpeg,
      );

      value = value.copyWith(
        isInitialized: true,
        previewWidth: await initializeCompleter.future.then((value) => value.previewWidth),
        previewHeight: await initializeCompleter.future.then((value) => value.previewHeight),
        flashMode: value.flashMode,
        exposureMode: value.exposureMode,
        exposurePointSupported: value.exposurePointSupported,
        focusMode: value.focusMode,
        focusPointSupported: value.focusPointSupported,
      );

      if (options != null) {
        _cameraOptions = options;
        setFlashMode(flashMode: options.flashMode ?? FlashMode.off);
        setExposureMode(exposureMode: options.exposureMode ?? ExposureMode.auto);
        setFocusMode(focusMode: options.focusMode ?? FocusMode.auto);
      }

      if (value.debugLogger) {
        SimpleCameraLogger.s("[Simple Camera] Initialize: Camera ${_description?.lensDirection}");
      }
    } on PlatformException catch (e) {
      _loggerCameraException(e.code, e.message);
      throw CameraException(e.code, e.message);
    }
  }

  /// Switch between back camera and front camera
  Future<void> switchCamera() async {
    final cameras = await availableCameras();

    if (_description?.lensDirection == CameraLensDirection.front) {
      initializeCamera(
        cameraDescription: cameras.firstWhere((cameraD) => cameraD.lensDirection == CameraLensDirection.back),
        options: _cameraOptions,
      );
    } else {
      initializeCamera(
        cameraDescription: cameras.firstWhere((cameraD) => cameraD.lensDirection == CameraLensDirection.front),
        options: _cameraOptions,
      );
    }
  }

  /// Toggle between flash on and off
  Future<void> switchFlash() async {
    switch (flashMode) {
      case FlashMode.off:
        setFlashMode(flashMode: FlashMode.always);
        break;
      case FlashMode.always:
        setFlashMode(flashMode: FlashMode.auto);
        break;
      case FlashMode.auto:
        setFlashMode(flashMode: FlashMode.torch);
        break;
      case FlashMode.torch:
        setFlashMode(flashMode: FlashMode.off);
        break;
    }
  }

  /// Start recording a video
  ///
  /// You can enter a maximum duration of the video
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<void> startVideoRecording({Duration? maxVideoDuration}) async {
    _throwIfCameraNotInitialized("startVideoRecording");

    if (value.isRecordingVideo) {
      if (value.debugLogger) {
        SimpleCameraLogger.w("[Simple Camera] Camera in use");
      }
      return;
    }

    try {
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Start Video Recording");
      }
      value = value.copyWith(isRecordingVideo: true);

      await _cameraPlatform.startVideoRecording(
        _cameraId,
        maxVideoDuration: maxVideoDuration,
      );
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Stop recording a video
  ///
  /// Returns the recording file
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<XFile> stopVideoRecording() async {
    _throwIfCameraNotInitialized("stopVideoRecording");

    try {
      value = value.copyWith(isRecordingVideo: false);
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Stop Video Recording");
      }
      value = value.copyWith(isRecordingVideo: false);
      final xFile = await _cameraPlatform.stopVideoRecording(_cameraId);
      return xFile;
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Start streaming video from platform camera
  ///
  /// The returned image format is set in the constructor
  ///
  /// You will want to use this method to perform real-time video streaming.
  ///
  /// You can enter a maximum duration of the video
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<Stream<CameraImageData>?> startVideoStream({Duration? maxVideoDuration}) async {
    _throwIfCameraNotInitialized("startVideoStream");

    if (value.isStreamingVideo) {
      if (value.debugLogger) {
        SimpleCameraLogger.w("[Simple Camera] Camera in use");
      }
      return null;
    }

    try {
      _videoStream = StreamController<CameraImageData>();

      _cameraPlatform.startVideoCapturing(VideoCaptureOptions(
        _cameraId,
        maxDuration: maxVideoDuration,
        streamCallback: (CameraImageData data) {
          _videoStream.add(data);
        },
      ));

      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Start Video Stream");
      }
      value = value.copyWith(isStreamingVideo: true);

      return _videoStream.stream;
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Stop streaming video
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<void> stopVideoStream() async {
    _throwIfCameraNotInitialized("stopVideoStream");

    try {
      await _videoStream.close();
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Stop Video Stream");
      }
      value = value.copyWith(isStreamingVideo: false);
    } on CameraException catch (e) {
      value = value.copyWith(isStreamingVideo: false);
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Take Picture
  Future<XFile?> takePicture() async {
    _throwIfCameraNotInitialized("takePicture");

    if (value.isTakingPicture) {
      if (value.debugLogger) {
        SimpleCameraLogger.w("[Simple Camera] Camera in use");
      }
      return null;
    }

    try {
      value = value.copyWith(isTakingPicture: true);
      final xFile = await _cameraPlatform.takePicture(_cameraId);
      value = value.copyWith(isTakingPicture: false);
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Take Picture");
      }
      return xFile;
    } on PlatformException catch (e) {
      value = value.copyWith(isTakingPicture: false);
      _loggerCameraException(e.code, e.message);
      throw CameraException(e.code, e.message);
    }
  }

  /// Change flash mode
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<void> setFlashMode({required FlashMode flashMode}) async {
    _throwIfCameraNotInitialized("setFlashMode");
    try {
      await _cameraPlatform.setFlashMode(_cameraId, flashMode);
      value = value.copyWith(flashMode: flashMode);
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Flash Mode: ${value.flashMode}");
      }
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Change exposure mode
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<void> setExposureMode({required ExposureMode exposureMode}) async {
    _throwIfCameraNotInitialized("setExposure");
    try {
      await _cameraPlatform.setExposureMode(_cameraId, exposureMode);
      value = value.copyWith(exposureMode: exposureMode);
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Exposure Mode: ${value.exposureMode}");
      }
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Change focus mode
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Future<void> setFocusMode({required FocusMode focusMode}) async {
    _throwIfCameraNotInitialized("setFocusMode");
    try {
      await _cameraPlatform.setFocusMode(_cameraId, focusMode);
      value = value.copyWith(focusMode: focusMode);
      if (value.debugLogger) {
        SimpleCameraLogger.i("[Simple Camera] Focus Mode: ${value.focusMode}");
      }
    } on CameraException catch (e) {
      _loggerCameraException(e.code, e.description);
      throw CameraException(e.code, e.description);
    }
  }

  /// Returns the preview of the output camera
  ///
  /// If in doubt, see [Examples] on how to use it.
  ///
  /// Returns [CameraException] if the camera has not been initialized
  Widget buildPreview() {
    _throwIfCameraNotInitialized("buildPreview");

    return _cameraPlatform.buildPreview(_cameraId);
  }

  /// Returns an exception if the camera is not initialized
  void _throwIfCameraNotInitialized(String fuctionName) {
    if (!value.isInitialized) {
      if (value.debugLogger) {
        SimpleCameraLogger.e("[Simple Camera] Camera not initialized");
      }
      throw CameraException(
        "Camera not initialized",
        "$fuctionName was called from the function",
      );
    }
  }

  void _loggerCameraException(String code, String? desc) {
    if (value.debugLogger) {
      SimpleCameraLogger.e("[Simple Camera] Camera Exception: [$code] $desc");
    }
  }

  // Releases the resources of this camera.
  @override
  Future<void> dispose() async {
    value = value.copyWith(isDisposed: true);
    await _cameraPlatform.pausePreview(_cameraId);
    await _cameraPlatform.dispose(_cameraId);
    if (value.debugLogger) {
      SimpleCameraLogger.s("[Simple Camera] Dispose");
    }
    value = value.copyWith(isStreamingVideo: false);
    super.dispose();
  }
}
