package com.rallypair.cv_rally_pair_log

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class CvRallyPairLogPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "cv_rally_pair_log/storage")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "getLogDirectory") {
            result.notImplemented()
            return
        }
        val appDirectory = context.getExternalFilesDir(null)
        if (appDirectory == null) {
            result.error("directory", "无法获取 App 日志目录", null)
            return
        }
        val directory = File(appDirectory, "Logs")
        if (!directory.exists() && !directory.mkdirs()) {
            result.error("directory", "无法创建日志目录", null)
            return
        }
        result.success(directory.absolutePath)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
