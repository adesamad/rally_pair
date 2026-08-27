import 'package:flutter/material.dart';

import '../rally_pair_theme.dart';

Future<String?> showPlayerNameDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String confirmLabel = '添加',
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PlayerNameDialog(
      title: title,
      initialValue: initialValue,
      confirmLabel: confirmLabel,
    ),
  );
}

Future<String?> showBatchPlayerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => const _BatchPlayerDialog(),
  );
}

class _PlayerNameDialog extends StatefulWidget {
  const _PlayerNameDialog({
    required this.title,
    required this.initialValue,
    required this.confirmLabel,
  });

  final String title;
  final String initialValue;
  final String confirmLabel;

  @override
  State<_PlayerNameDialog> createState() => _PlayerNameDialogState();
}

class _PlayerNameDialogState extends State<_PlayerNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = '请输入玩家名称');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: (_) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: '玩家名称',
          hintText: '例如：小林',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

class _BatchPlayerDialog extends StatefulWidget {
  const _BatchPlayerDialog();

  @override
  State<_BatchPlayerDialog> createState() => _BatchPlayerDialogState();
}

class _BatchPlayerDialogState extends State<_BatchPlayerDialog> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      setState(() => _errorText = '请粘贴或输入玩家名单');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('批量添加玩家'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每行一名玩家，空行会忽略，重名会自动跳过。',
              style: TextStyle(color: RallyPairColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: 5,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              decoration: InputDecoration(
                hintText: '小林\n阿杰\n晓雨',
                errorText: _errorText,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('加入名单')),
      ],
    );
  }
}
