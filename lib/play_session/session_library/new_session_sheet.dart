import 'package:flutter/material.dart';

import '../../rally_pair_widgets/rt_rally_pair_input/rt_rally_pair_input.dart';
import '../../zf_rally_pair_app/zf_rally_pair_app.dart';
import '../session_models.dart';
import '../session_store.dart';

Future<int?> showNewSessionSheet(BuildContext context, PlaySessionStore store) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _NewSessionSheet(store: store),
  );
}

class _NewSessionSheet extends StatefulWidget {
  const _NewSessionSheet({required this.store});

  final PlaySessionStore store;

  @override
  State<_NewSessionSheet> createState() => _NewSessionSheetState();
}

class _NewSessionSheetState extends State<_NewSessionSheet> {
  final _titleController = TextEditingController();
  var _courtCount = 2;
  var _pairingPolicy = PairingPolicy.fairRotation;
  var _scorePreset = ScorePreset.standard21;
  var _avoidRecentPartner = true;
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final id = await widget.store.createSession(
        SessionDraftInput(
          title: _titleController.text,
          courtCount: _courtCount,
          pairingPolicy: _pairingPolicy,
          scorePreset: _scorePreset,
          avoidRecentPartner: _avoidRecentPartner,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } on SessionRuleException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '创建失败，请稍后重试';
      });
    }
  }

  void _changeCourtCount(int delta) {
    final next = (_courtCount + delta).clamp(1, 8);
    if (next == _courtCount) return;
    setState(() => _courtCount = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Material(
        color: ZfRallyPairColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: _SheetHandle()),
                const SizedBox(height: 18),
                Text('创建球局', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '先保存基本设置，稍后继续维护到场名单。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ZfRallyPairColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),
                Text('球局名称', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                RtRallyPairInputField(
                  key: const Key('new-session-title'),
                  controller: _titleController,
                  autofocus: true,
                  hintText: '例如：周三晚场',
                  maxLength: 40,
                  borderRadius: 14,
                  backgroundColor: ZfRallyPairColors.surface,
                  border: Border.all(color: ZfRallyPairColors.surfaceSoft),
                ),
                const SizedBox(height: 18),
                _CourtCountField(
                  count: _courtCount,
                  onDecrease: () => _changeCourtCount(-1),
                  onIncrease: () => _changeCourtCount(1),
                ),
                const SizedBox(height: 18),
                _ChoiceField<PairingPolicy>(
                  title: '分组策略',
                  value: _pairingPolicy,
                  values: PairingPolicy.values,
                  label: (value) => value.label,
                  onChanged: (value) => setState(() => _pairingPolicy = value),
                ),
                const SizedBox(height: 18),
                _ChoiceField<ScorePreset>(
                  title: '比分预设',
                  value: _scorePreset,
                  values: ScorePreset.values,
                  label: (value) => value.label,
                  onChanged: (value) => setState(() => _scorePreset = value),
                ),
                const SizedBox(height: 10),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('尽量避免连续重复搭档'),
                  subtitle: const Text('无法满足时仍允许生成公平组合'),
                  value: _avoidRecentPartner,
                  onChanged: (value) {
                    setState(() => _avoidRecentPartner = value);
                  },
                ),
                if (_error case final error?) ...[
                  const SizedBox(height: 6),
                  Text(
                    error,
                    key: const Key('new-session-error'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: ZfRallyPairColors.danger,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  key: const Key('create-session-submit'),
                  onPressed: _saving ? null : _create,
                  child: Text(_saving ? '正在创建…' : '创建球局'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 4,
      decoration: BoxDecoration(
        color: ZfRallyPairColors.textSecondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CourtCountField extends StatelessWidget {
  const _CourtCountField({
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int count;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text('场地数量', style: theme.textTheme.titleSmall)),
        _CountButton(
          label: '−',
          semanticLabel: '减少场地',
          enabled: count > 1,
          onPressed: onDecrease,
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        _CountButton(
          label: '＋',
          semanticLabel: '增加场地',
          enabled: count < 8,
          onPressed: onIncrease,
        ),
      ],
    );
  }
}

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.label,
    required this.semanticLabel,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 44,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: const BorderSide(color: ZfRallyPairColors.surfaceSoft),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: ExcludeSemantics(
            child: Text(label, style: const TextStyle(fontSize: 22)),
          ),
        ),
      ),
    );
  }
}

class _ChoiceField<T> extends StatelessWidget {
  const _ChoiceField({
    required this.title,
    required this.value,
    required this.values,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in values)
              ChoiceChip(
                label: Text(label(option)),
                selected: value == option,
                showCheckmark: false,
                onSelected: (_) => onChanged(option),
              ),
          ],
        ),
      ],
    );
  }
}
