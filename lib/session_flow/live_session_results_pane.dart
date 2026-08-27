part of 'live_session_page.dart';

class _ResultsPane extends StatelessWidget {
  const _ResultsPane({required this.session});

  final PlaySession session;

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
            _ResultCard(match: completed[index], names: names),
            if (index != completed.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.match, required this.names});

  final SessionMatch match;
  final Map<int, String> names;

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
        ],
      ),
    );
  }
}

class _WinnerDialog extends StatelessWidget {
  const _WinnerDialog({required this.match, required this.names});

  final SessionMatch match;
  final Map<int, String> names;

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
            onPressed: () => Navigator.of(context).pop(Side.a),
          ),
          const SizedBox(height: 10),
          _WinnerChoice(
            label: 'B 组获胜',
            names: _teamName(match.teamB, names),
            onPressed: () => Navigator.of(context).pop(Side.b),
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
