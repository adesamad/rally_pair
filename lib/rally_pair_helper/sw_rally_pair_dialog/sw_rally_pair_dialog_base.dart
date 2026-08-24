import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class SwRallyPairDialogBase {
  SwRallyPairDialogBase._();

  static Future<void> dismiss({String? tag, Object? result}) {
    return SmartDialog.dismiss(tag: tag, result: result);
  }

  static Future<void> showLoading({
    String message = '加载中…',
    bool? clickMaskDismiss,
    VoidCallback? onDismiss,
  }) {
    return SmartDialog.showLoading(
      msg: message,
      clickMaskDismiss: clickMaskDismiss,
      onDismiss: onDismiss,
    );
  }

  static Future<void> hideLoading() {
    return SmartDialog.dismiss(status: SmartStatus.loading);
  }

  static Future<T?> show<T>({
    required Widget child,
    String? tag,
    Alignment alignment = Alignment.center,
    bool keepSingle = true,
    bool clickMaskDismiss = true,
    bool backDismiss = true,
    bool bindPage = true,
    VoidCallback? onDismiss,
  }) {
    return SmartDialog.show<T>(
      tag: tag,
      alignment: alignment,
      keepSingle: keepSingle,
      clickMaskDismiss: clickMaskDismiss,
      backType: backDismiss ? SmartBackType.normal : SmartBackType.ignore,
      bindPage: bindPage,
      onDismiss: onDismiss,
      builder: (_) => child,
    );
  }
}
