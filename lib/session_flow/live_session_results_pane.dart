part of 'live_session_page.dart';

class _ResultsPane extends StatelessWidget {
  const _ResultsPane({required this.session, required this.onCorrect});

  final PlaySession session;
  final ValueChanged<SessionMatch> onCorrect;

  @override
  Widget build(BuildContext context) {
    final names = _playerNames(session);
    final completed =
        session.matches
            .where((match) => match.state == MatchState.completed)
            .toList()
          ..sort(
            (left, right) =>
                right.completedOrder!.compareTo(left.completedOrder!),
          );
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(title: '比赛结果', description: '按完成顺序查看本场已经登记的胜方。'),
        const SizedBox(height: 18),
        if (completed.isEmpty)
          const _SimpleEmpty(message: '还没有完成的比赛。')
        else
          for (var index = 0; index < completed.length; index++) ...[
            _ResultCard(
              match: completed[index],
              names: names,
              onCorrect: () => onCorrect(completed[index]),
            ),
            if (index != completed.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.match,
    required this.names,
    required this.onCorrect,
  });

  final SessionMatch match;
  final Map<int, String> names;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final winner = match.result!.winner;
    final winningTeam = winner == Side.a ? match.teamA : match.teamB;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${match.courtNumber} 号场 · 第 ${match.completedOrder} 场完成',
            style: const TextStyle(color: RallyPairColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Text(
            '${winner == Side.a ? 'A' : 'B'} 组获胜',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            _teamName(winningTeam, names),
            style: const TextStyle(
              color: RallyPairColors.court,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (match.result!.games.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              match.result!.games
                  .map((game) => '${game.a}:${game.b}')
                  .join('  '),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onCorrect, child: const Text('修正结果')),
          ),
        ],
      ),
    );
  }
}

class _WinnerDialog extends StatelessWidget {
  const _WinnerDialog({
    required this.match,
    required this.names,
    required this.scorePreset,
  });

  final SessionMatch match;
  final Map<int, String> names;
  final ScorePreset scorePreset;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${match.courtNumber} 号场谁赢了？'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WinnerChoice(
            label: 'A 组获胜',
            names: _teamName(match.teamA, names),
            onPressed: () =>
                Navigator.of(context).pop(MatchResult.winnerOnly(Side.a)),
          ),
          const SizedBox(height: 10),
          _WinnerChoice(
            label: 'B 组获胜',
            names: _teamName(match.teamB, names),
            onPressed: () =>
                Navigator.of(context).pop(MatchResult.winnerOnly(Side.b)),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              final result = await showDialog<MatchResult>(
                context: context,
                builder: (_) => _GameScoreDialog(preset: scorePreset),
              );
              if (context.mounted && result != null) {
                Navigator.of(context).pop(result);
              }
            },
            child: const Text('录入各局比分'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('暂不记录'),
        ),
      ],
    );
  }
}

class _GameScoreDialog extends StatefulWidget {
  const _GameScoreDialog({required this.preset});

  final ScorePreset preset;

  @override
  State<_GameScoreDialog> createState() => _GameScoreDialogState();
}

class _GameScoreDialogState extends State<_GameScoreDialog> {
  late final List<TextEditingController> _a;
  late final List<TextEditingController> _b;
  String? _error;

  @override
  void initState() {
    super.initState();
    final count = widget.preset == ScorePreset.quick11 ? 1 : 3;
    _a = List.generate(count, (_) => TextEditingController());
    _b = List.generate(count, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in [..._a, ..._b]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final games = <GameScore>[];
    for (var index = 0; index < _a.length; index++) {
      final a = int.tryParse(_a[index].text.trim());
      final b = int.tryParse(_b[index].text.trim());
      if (a == null && b == null && index == 2) continue;
      if (a == null || b == null) {
        setState(() => _error = '请把每一局双方比分填写完整。');
        return;
      }
      games.add(GameScore(a, b));
    }
    try {
      Navigator.of(context).pop(MatchResult.gameScores(games));
    } on RuleViolation {
      setState(() => _error = '比分需要产生唯一胜方。');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('录入各局比分'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < _a.length; index++) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _a[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '第${index + 1}局 A'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(':'),
                ),
                Expanded(
                  child: TextField(
                    controller: _b[index],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '第${index + 1}局 B'),
                  ),
                ),
              ],
            ),
            if (index != _a.length - 1) const SizedBox(height: 8),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: RallyPairColors.danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(onPressed: _submit, child: const Text('保存比分')),
      ],
    );
  }
}

class _WinnerChoice extends StatelessWidget {
  const _WinnerChoice({
    required this.label,
    required this.names,
    required this.onPressed,
  });

  final String label;
  final String names;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            names,
            style: const TextStyle(
              color: RallyPairColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
