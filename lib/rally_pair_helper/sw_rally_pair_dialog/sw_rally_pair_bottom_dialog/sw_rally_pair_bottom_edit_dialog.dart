import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:rally_pair/rally_pair_widgets/rt_rally_pair_input/rt_rally_pair_input.dart';

class SwRallyPairBottomEditDialog extends StatefulWidget {
  const SwRallyPairBottomEditDialog({
    super.key,
    this.controller,
    this.hintText = '',
    this.initialText,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String hintText;
  final String? initialText;
  final ValueChanged<String>? onChanged;

  @override
  State<SwRallyPairBottomEditDialog> createState() =>
      _SwRallyPairBottomEditDialogState();
}

class _SwRallyPairBottomEditDialogState
    extends State<SwRallyPairBottomEditDialog> {
  final _focusNode = FocusNode();
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialText);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                14 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: RtRallyPairInputField(
                controller: _controller,
                focusNode: _focusNode,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                borderRadius: 10,
                hintText: widget.hintText,
                maxLines: 5,
                onChanged: widget.onChanged,
              ),
            ),
          ),
        );
      },
    );
  }
}
