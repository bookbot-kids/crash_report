import 'dart:async';

import 'package:flutter/services.dart';

class CrashReport {
  static const MethodChannel _channel = const MethodChannel('crash_report');

  static Future<String> setup() async {
    return await _channel.invokeMethod('setup');
  }

  static Future<void> crash() async {
    await _channel.invokeMethod('crash');
  }
}
