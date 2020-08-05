package com.bookbot.crash_report.crash_report

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.io.FileOutputStream
import java.util.*


/** CrashReportPlugin */
class CrashReportPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var context: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "crash_report")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
        "setup" -> {
          setup()
          result.success("OK")
        }
        "crash" -> {
          crash()
          result.success("OK")
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /** Force a test crash
  */
  private fun crash() {
    throw Exception("Test crash")
  }

  /**
   * Setup the crash handler
   */
  private fun setup() {
    val defaultHandler = Thread.getDefaultUncaughtExceptionHandler()
    Thread.setDefaultUncaughtExceptionHandler { thread, throwable ->
      val stackTrace = Log.getStackTraceString(throwable)
      val message = throwable?.message ?: ""
      Log.d("CrashReportPlugin", "catch exception $message")
      val content = "$message####$stackTrace"
      context?.filesDir?.let { dir ->
        Thread {
          val fileName = UUID.randomUUID().toString() + ".txt"
          dir.mkdirs()
          val file = File(dir, fileName)
          Log.d("CrashReportPlugin", "save crash to file ${file.absolutePath}")
          val stream = FileOutputStream(file)
          stream.use { s ->
            s.write(content.toByteArray())
            Log.d("CrashReportPlugin", "Save success")
          }
        }.start()
      }

      defaultHandler?.uncaughtException(thread, throwable)
    }
  }
}
