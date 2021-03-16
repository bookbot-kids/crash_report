import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_io/io.dart';
import 'package:universal_platform/universal_platform.dart';

/// Crash report tool
class CrashReport {
  CrashReport._privateConstructor();

  /// singleton instance
  static final CrashReport shared = CrashReport._privateConstructor();

  final MethodChannel _channel = const MethodChannel('crash_report');
  Logger _logger;

  static Future init(Logger logger) async {
    shared._logger = logger;
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await shared._channel.invokeMethod('setup');
      await shared.collectCrashReports();
    }
  }

  /// Test native crash
  Future<void> crash() async {
    await _channel.invokeMethod('crash');
  }

  /// Record flutter error
  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    _logger?.wtf(
        'flutter error ${details.exception}', details.exception, details.stack);
  }

  /// Execute a function in [runZoned] and handle error logging
  ///
  /// [runZoned]:(https://api.flutter.dev/flutter/dart-async/runZoned.html)
  void executeInZoned(Function func) {
    runZonedGuarded(() {
      func();
    }, (e, stackTrace) {
      _logger?.wtf('runZoned error $e', e, stackTrace);
    });
  }

  /// Collect all crash report files saved in ios & android device
  /// The log file is a text file with following content: crashName####stacktrace
  Future<void> collectCrashReports() async {
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      try {
        final dir = await getApplicationSupportDirectory();
        if (await dir.exists()) {
          // list all files in log dir
          var files = dir.listSync(recursive: false);
          if (files.isNotEmpty) {
            for (var entry in files) {
              // Only read the text file
              if (!entry.path.endsWith('.txt')) {
                continue;
              }

              var f = File(entry.path);
              var content = await f.readAsString();
              var parts = content.split('####');
              var errorName = parts.length == 2 ? parts[0] : 'CrashReport';
              _logger.wtf(errorName, Exception(errorName),
                  StackTrace.fromString(content));

              // delete file after sending
              await f.delete();
            }
          }
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
