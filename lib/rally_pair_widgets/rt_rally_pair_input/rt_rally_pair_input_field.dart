import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RtRallyPairInputField extends StatefulWidget {
  const RtRallyPairInputField({
    super.key,
    this.keyboardType = TextInputType.text,
    this.hintText = '',
    this.controller,
    this.style,
    this.hintStyle,
    this.contentPadding,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
    this.obscureText = false,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    this.minHeight = 48,
    this.prefix,
    this.suffix,
    this.backgroundColor,
    this.borderRadius = 0,
    this.border,
    this.textAlign = TextAlign.start,
    this.counterTextVisible = false,
    this.onTap,
  });

  final TextInputType keyboardType;
  final String hintText;
  final TextEditingController? controller;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final EdgeInsets? contentPadding;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final EdgeInsets padding;
  final double minHeight;
  final Widget? prefix;
  final Widget? suffix;
  final Color? backgroundColor;
  final double borderRadius;
  final BoxBorder? border;
  final TextAlign textAlign;
  final bool counterTextVisible;
  final VoidCallback? onTap;

  @override
  State<RtRallyPairInputField> createState() => _RtRallyPairInputFieldState();
}

class _RtRallyPairInputFieldState extends State<RtRallyPairInputField> {
  late TextEditingController _controller;
  late bool _ownsController;

  @override
  void initState() {
    super.initState();
    _attachController();
  }

  @override
  void didUpdateWidget(covariant RtRallyPairInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    _detachController();
    _attachController();
  }

  @override
  void dispose() {
    _detachController();
    super.dispose();
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _detachController() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
  }

  void _onTextChanged() {
    if (mounted && widget.counterTextVisible) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: widget.padding,
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border,
      ),
      child: Row(
        children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              focusNode: widget.focusNode,
              autofocus: widget.autofocus,
              obscureText: widget.obscureText,
              textAlign: widget.textAlign,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle:
                    widget.hintStyle ??
                    theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                contentPadding: widget.contentPadding ?? EdgeInsets.zero,
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.transparent,
                isDense: true,
                counterText: widget.counterTextVisible
                    ? '${_controller.text.length}/${widget.maxLength}'
                    : '',
              ),
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              style: widget.style ?? theme.textTheme.bodyMedium,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
      ),
    );
  }
}
