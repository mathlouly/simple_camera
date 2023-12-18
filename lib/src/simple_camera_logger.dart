import 'package:flutter/foundation.dart';

class SimpleCameraLogger {
  static String _redColor(String message) {
    return "\x1B[31m$message\x1B[0m";
  }

  static String _greenColor(String message) {
    return "\x1B[32m$message\x1B[0m";
  }

  static String _yellowColor(String message) {
    return "\x1B[33m$message\x1B[0m";
  }

  static String _magentaColor(String message) {
    return "\x1B[35m$message\x1B[0m";
  }

  static void e(String message) {
    if (kDebugMode) {
      print(_redColor(message));
    }
  }

  static void s(String message) {
    if (kDebugMode) {
      print(_greenColor(message));
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      print(_yellowColor(message));
    }
  }

  static void i(String message) {
    if (kDebugMode) {
      print(_magentaColor(message));
    }
  }
}
