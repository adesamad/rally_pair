import 'package:flutter/material.dart';

import '../play_session/play_session.dart';
import '../rally_pair_theme.dart';
import '../session_flow/live_session_page.dart';
import '../session_flow/rule_violation_message.dart';

class SessionSummaryPage extends StatefulWidget {
  const SessionSummaryPage({
    super.key,
    required this.store,
    required this.sessionId,
  });

  final PlaySessionStore store;
  final int sessionId;

  @override
  State<SessionSummaryPage> createState() => _SessionSummaryPageState();
}

class _SessionSummaryPageState extends State<SessionSummaryPage> {
  PlaySession? _session;
  Object? _error;
  var _loading = true;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await widget.store.load(widget.sessionId);
      if (session == null) throw const RuleViolation('session_not_found');
      if (session.status != SessionStatus.completed) {
        throw const RuleViolation('session_not_completed');
      }
      if (!mounted) return;
      setState(() {
        _session = session;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _correct(SessionMatch match) async {
    final session = _session;
    if (session == null || _busy) return;
    final names = {
      for (final player in session.players) player.id: player.name,
    };
    final result = await showMatchResultDialog(
      context,
      match: match,
      names: names,
      scorePreset: session.setup.scorePreset,
    );
    if (!mounted || result == null) return;
    setState(() => _busy = true);
    try {
      final updated = await widget.store.update(
        widget.sessionId,
        (value) => value.correctMatch(match.id, result),
      );
      if (!mounted) return;
      setState(() {
        _session = updated;
        _busy = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('比赛结果已修正，球友统计已重新计算。')));
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ruleViolationMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.setup.title ?? '球局总结'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: switch ((_loading, _error, session)) {
          (true, _, _) => const Center(child: CircularProgressIndicator()),
          (false, final error?, _) => _SummaryError(
            message: ruleViolationMessage(error),
            onRetry: _load,
          ),
          (false, null, final value?) => _SummaryContent(
            session: value,
            busy: _busy,
            onCorrect: _correct,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _SummaryContent extends StatelessWidget {
  const _SummaryContent({
    required this.session,
    required this.busy,
    required this.onCorrect,
  });

  final PlaySession session;
  final bool busy;
  final ValueChanged<SessionMatch> onCorrect;

  @override
  Widget build(BuildContext context) {
    final completed =
        session.matches
            .where((match) => match.state == MatchState.completed)
            .toList()
          ..sort(
            (left, right) =>
                right.completedOrder!.compareTo(left.completedOrder!),
          );
    final names = {
      for (final player in session.players) player.id: player.name,
    };
    final stats = session.stats.values.toList()
      ..sort((left, right) {
        final wins = right.wins.compareTo(left.wins);
        if (wins != 0) return wins;
        final matches = right.completedMatches.compareTo(left.completedMatches);
        if (matches != 0) return matches;
        return (names[left.playerId] ?? '').compareTo(
          names[right.playerId] ?? '',
        );
      });
    return ListView(
      key: const PageStorageKey('session-summary'),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('本场总结', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text(
                  '球局已结束，这里保留比赛结果和球友统计。',
                  style: TextStyle(color: RallyPairColors.textSecondary),
                ),
                const SizedBox(height: 18),
                _SummaryMetrics(
                  players: session.players.length,
                  courts: session.courts.length,
                  matches: completed.length,
                ),
                const SizedBox(height: 26),
                Text('球友表现', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                for (var index = 0; index < stats.length; index++) ...[
                  _PlayerStatsRow(
                    name: names[stats[index].playerId] ?? '未知球友',
                    stats: stats[index],
                  ),
                  if (index != stats.length - 1) const SizedBox(height: 8),
                ],
                const SizedBox(height: 26),
                Text('比赛记录', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (completed.isEmpty)
                  const _SummaryEmpty()
                else
                  for (var index = 0; index < completed.length; index++) ...[
                    _SummaryMatchCard(
                      match: completed[index],
                      names: names,
                      busy: busy,
                      onCorrect: () => onCorrect(completed[index]),
                    ),
                    if (index != completed.length - 1)
                      const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({
    required this.players,
    required this.courts,
    required this.matches,
  });

  final int players;
  final int courts;
  final int matches;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Metric(label: '球友', value: '$players 人'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Metric(label: '场地', value: '$courts 块'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Metric(label: '完成', value: '$matches 场'),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: RallyPairColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerStatsRow extends StatelessWidget {
  const _PlayerStatsRow({required this.name, required this.stats});

  final String name;
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    final hasPoints = stats.pointsFor > 0 || stats.pointsAgainst > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: Theme.of(context).textTheme.titleMedium),
          ),
          Text(
            '${stats.wins} 胜 ${stats.losses} 负',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          if (hasPoints) ...[
            const SizedBox(width: 12),
            Text(
              '${stats.pointsFor}:${stats.pointsAgainst}',
              style: const TextStyle(color: RallyPairColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryMatchCard extends StatelessWidget {
  const _SummaryMatchCard({
    required this.match,
    required this.names,
    required this.busy,
    required this.onCorrect,
  });

  final SessionMatch match;
  final Map<int, String> names;
  final bool busy;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final result = match.result!;
    final winner = result.winner == Side.a ? match.teamA : match.teamB;
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
            '${match.courtNumber} 号场 · 第 ${match.completedOrder} 场',
            style: const TextStyle(color: RallyPairColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '${names[winner.first]} · ${names[winner.second]} 获胜',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (result.games.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              result.games.map((game) => '${game.a}:${game.b}').join('  '),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: busy ? null : onCorrect,
              child: const Text('修正结果'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryEmpty extends StatelessWidget {
  const _SummaryEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: const Text(
        '本场未产生有效比赛。',
        textAlign: TextAlign.center,
        style: TextStyle(color: RallyPairColors.textSecondary),
      ),
    );
  }
}

class _SummaryError extends StatelessWidget {
  const _SummaryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('重新读取')),
          ],
        ),
      ),
    );
  }
}
