import 'dart:async';

import 'package:flutter/material.dart';

import 'sw_rally_pair_dialog_base.dart';

class SwRallyPairDialog {
  SwRallyPairDialog._();

  static const confirmTag = 'swRallyPairConfirmDialog';

  static Future<bool?> confirm({
    required String title,
    required String content,
    String confirmText = '确认',
    String cancelText = '取消',
    bool showCancel = true,
    bool clickMaskDismiss = true,
    bool backDismiss = true,
  }) {
    final completer = Completer<bool?>();
    final child = Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(title),
          content: SelectableText(content),
          actions: [
            if (showCancel)
              TextButton(
                onPressed: () => _complete(completer, false),
                child: Text(cancelText),
              ),
            FilledButton(
              onPressed: () => _complete(completer, true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    SwRallyPairDialogBase.show<void>(
      tag: confirmTag,
      child: child,
      clickMaskDismiss: clickMaskDismiss,
      backDismiss: backDismiss,
      onDismiss: () {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    return completer.future;
  }

  static Future<T?> choose<T>({
    required String title,
    required List<SwRallyPairDialogOption<T>> options,
    String? tag,
  }) {
    final completer = Completer<T?>();
    final child = Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Text(title, style: theme.textTheme.titleMedium),
                ),
                for (final option in options)
                  ListTile(
                    title: Text(option.label),
                    onTap: () => _complete(completer, option.value, tag: tag),
                  ),
              ],
            ),
          ),
        );
      },
    );
    SwRallyPairDialogBase.show<void>(
      tag: tag,
      child: child,
      alignment: Alignment.bottomCenter,
      bindPage: false,
      onDismiss: () {
        if (!completer.isCompleted) completer.complete(null);
      },
    );
    return completer.future;
  }

  static Future<void> dismiss({String? tag, Object? result}) {
    return SwRallyPairDialogBase.dismiss(tag: tag, result: result);
  }

  static void _complete<T>(Completer<T?> completer, T value, {String? tag}) {
    if (!completer.isCompleted) completer.complete(value);
    dismiss(tag: tag ?? confirmTag);
  }
}

class SwRallyPairDialogOption<T> {
  const SwRallyPairDialogOption({required this.label, required this.value});

  final String label;
  final T value;
}
