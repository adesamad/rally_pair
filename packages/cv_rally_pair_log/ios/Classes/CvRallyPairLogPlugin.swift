import Flutter
import UIKit

public final class CvRallyPairLogPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "cv_rally_pair_log/storage",
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(CvRallyPairLogPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getLogDirectory" else {
      result(FlutterMethodNotImplemented)
      return
    }
    do {
      let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
      let directory = documents.appendingPathComponent("Logs", isDirectory: true)
      try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
      result(directory.path)
    } catch {
      result(FlutterError(code: "directory", message: "无法创建日志目录", details: error.localizedDescription))
    }
  }
}
