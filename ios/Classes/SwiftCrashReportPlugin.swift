import Flutter
import UIKit

public class SwiftCrashReportPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "crash_report", binaryMessenger: registrar.messenger())
    let instance = SwiftCrashReportPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /**
    Handle platform method
  */
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Setup the crash handler
    if call.method == "setup" {
      setup()
      result("OK")
    } else if call.method == "crash" {
      crash()
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

   // force a test crash
  func crash() {
    let error: NSError? = nil
    NSException.raise(NSExceptionName(rawValue: "Test native Crash"), format:"Error: %@", arguments:getVaList([error ?? "nil"]))
  }

  /**
    Setup the crash handler
  */
  func setup() {
      NSSetUncaughtExceptionHandler { exception in
        let name = exception.name
        let stackTrace = exception.callStackSymbols.joined(separator: "\n")
        let content = "\(name)####\(stackTrace)"
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let uuid = UUID().uuidString
        let filename = paths.appendingPathComponent("\(uuid).txt")
        // create folder in application support
        try? FileManager.default.createDirectory(at: paths, withIntermediateDirectories: true, attributes: nil)
        do {
            try content.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("write error")
        }
      }
  }
}
