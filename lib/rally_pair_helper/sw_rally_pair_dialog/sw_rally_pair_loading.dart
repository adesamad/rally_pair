import 'package:flutter/material.dart';

import 'sw_rally_pair_dialog_base.dart';

class SwRallyPairLoading {
  SwRallyPairLoading._();

  static void show({String message = '加载中…', VoidCallback? onDismiss}) {
    SwRallyPairDialogBase.showLoading(message: message, onDismiss: onDismiss);
  }

  static Future<void> hide() => SwRallyPairDialogBase.hideLoading();
}
