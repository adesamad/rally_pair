import 'package:flutter/material.dart';

import '../play_session/models.dart';
import '../rally_pair_theme.dart';

class SessionSetupPage extends StatefulWidget {
  const SessionSetupPage({super.key, this.initialSetup});

  final SessionSetup? initialSetup;

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  final _title = TextEditingController();
  var _courtCount = 0;
  var _scorePreset = ScorePreset.standard21;
  var _rotationMode = RotationMode.winnerStays;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final setup = widget.initialSetup;
    if (setup != null) {
      _title.text = setup.title;
      _courtCount = setup.courtCount;
      _scorePreset = setup.scorePreset;
      _rotationMode = setup.defaultRotationMode;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '请输入球局名称');
      return;
    }
    Navigator.of(context).pop(
      SessionSetup(
        title: title,
        courtCount: _courtCount,
        scorePreset: _scorePreset,
        randomSeed:
            widget.initialSetup?.randomSeed ??
            DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF,
        defaultRotationMode: _rotationMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.initialSetup == null ? '新建球局' : '调整球局设置'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: FilledButton(
            onPressed: _submit,
            child: Text(widget.initialSetup == null ? '创建球局' : '保存设置'),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '先定好本场规则',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '创建后再添加玩家，开始前仍可调整这些设置。',
                    style: TextStyle(color: RallyPairColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _title,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      if (_titleError != null) {
                        setState(() => _titleError = null);
                      }
                    },
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: '球局名称',
                      hintText: '例如：周六晚场',
                      errorText: _titleError,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SetupSection(
                    title: '场地数量',
                    child: _CourtCountField(
                      value: _courtCount,
                      onChanged: (value) {
                        setState(() => _courtCount = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupSection(
                    title: '默认上下场方式',
                    child: SegmentedButton<RotationMode>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: RotationMode.winnerStays,
                          label: Text('胜方留场'),
                        ),
                        ButtonSegment(
                          value: RotationMode.allRotate,
                          label: Text('两组下场'),
                        ),
                      ],
                      selected: {_rotationMode},
                      onSelectionChanged: (selection) {
                        setState(() => _rotationMode = selection.single);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SetupSection(
                    title: '比分预设',
                    child: SegmentedButton<ScorePreset>(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(
                          value: ScorePreset.quick11,
                          label: Text('11 分快赛'),
                        ),
                        ButtonSegment(
                          value: ScorePreset.standard21,
                          label: Text('21 分标准'),
                        ),
                      ],
                      selected: {_scorePreset},
                      onSelectionChanged: (selection) {
                        setState(() => _scorePreset = selection.single);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupSection extends StatelessWidget {
  const _SetupSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _CourtCountField extends StatelessWidget {
  const _CourtCountField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$value 块场地',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _CountButton(
          label: '−',
          semanticLabel: '减少场地',
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        const SizedBox(width: 10),
        _CountButton(
          label: '+',
          semanticLabel: '增加场地',
          onPressed: value < 8 ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}

class _CountButton extends StatelessWidget {
  const _CountButton({
    required this.label,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String label;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox.square(
        dimension: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          child: ExcludeSemantics(
            child: Text(label, style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}
