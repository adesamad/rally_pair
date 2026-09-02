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
    final stats = session.stats;
    final performances =
        stats.values
            .where((value) => value.completedMatches > 0)
            .map(
              (value) => _PlayerPerformance(
                name: names[value.playerId] ?? '未知球友',
                stats: value,
                scoredMatches: completed
                    .where(
                      (match) =>
                          match.contains(value.playerId) &&
                          match.result?.mode == ResultMode.gameScores,
                    )
                    .length,
                frequentPartnerName: _frequentPartnerName(value, names),
              ),
            )
            .toList()
          ..sort(_comparePerformance);
    final noAppearanceNames = stats.values
        .where((value) => value.completedMatches == 0)
        .map((value) => names[value.playerId] ?? '未知球友')
        .toList(growable: false);
    final totalAppearances = stats.values.fold<int>(
      0,
      (sum, value) => sum + value.completedMatches,
    );
    final averageAppearances = session.players.isEmpty
        ? 0.0
        : totalAppearances / session.players.length;
    final appearanceCounts = stats.values
        .map((value) => value.completedMatches)
        .toList(growable: false);
    final appearanceSpread = appearanceCounts.isEmpty
        ? 0
        : appearanceCounts.reduce(_max) - appearanceCounts.reduce(_min);
    final insight = _sessionInsight(
      completedMatches: completed.length,
      participantCount: performances.length,
      totalPlayers: session.players.length,
      noAppearanceCount: noAppearanceNames.length,
      appearanceSpread: appearanceSpread,
    );
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
                Text(
                  '${session.setup.matchFormat == MatchFormat.singles ? '单打' : '双打'} · '
                  '${session.setup.scorePreset == ScorePreset.quick11 ? '11 分' : '21 分'} · 已结束',
                  style: TextStyle(color: RallyPairColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _SessionInsight(message: insight),
                const SizedBox(height: 12),
                _SummaryMetrics(
                  matches: completed.length,
                  participants: performances.length,
                  players: session.players.length,
                  averageAppearances: averageAppearances,
                ),
                const SizedBox(height: 26),
                const _SectionHeader(
                  title: '球友表现',
                  description: '按本场胜率、胜场和出场数排序；小样本只作为本场记录。',
                ),
                const SizedBox(height: 12),
                if (performances.isEmpty)
                  const _PerformanceEmpty()
                else
                  for (var index = 0; index < performances.length; index++) ...[
                    _PlayerStatsRow(performance: performances[index]),
                    if (index != performances.length - 1)
                      const SizedBox(height: 8),
                  ],
                if (noAppearanceNames.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _NoAppearancePanel(names: noAppearanceNames),
                ],
                const SizedBox(height: 26),
                if (completed.isEmpty)
                  const _SummaryEmpty()
                else
                  _MatchHistory(
                    matches: completed,
                    names: names,
                    showCourt: session.courts.length > 1,
                    busy: busy,
                    onCorrect: onCorrect,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

int _min(int left, int right) => left < right ? left : right;

int _max(int left, int right) => left > right ? left : right;

int _comparePerformance(_PlayerPerformance left, _PlayerPerformance right) {
  final rate = (right.stats.wins * left.stats.completedMatches).compareTo(
    left.stats.wins * right.stats.completedMatches,
  );
  if (rate != 0) return rate;
  final wins = right.stats.wins.compareTo(left.stats.wins);
  if (wins != 0) return wins;
  final matches = right.stats.completedMatches.compareTo(
    left.stats.completedMatches,
  );
  if (matches != 0) return matches;
  return left.name.compareTo(right.name);
}

String? _frequentPartnerName(PlayerStats stats, Map<int, String> names) {
  if (stats.partners.isEmpty) return null;
  final partners = stats.partners.entries.toList()
    ..sort((left, right) {
      final matches = right.value.compareTo(left.value);
      if (matches != 0) return matches;
      return (names[left.key] ?? '').compareTo(names[right.key] ?? '');
    });
  return names[partners.first.key];
}

String _sessionInsight({
  required int completedMatches,
  required int participantCount,
  required int totalPlayers,
  required int noAppearanceCount,
  required int appearanceSpread,
}) {
  if (completedMatches == 0) {
    return '本场没有完成的比赛，因此还没有可统计的球友表现。';
  }
  if (noAppearanceCount > 0) {
    return '本场有 $participantCount / $totalPlayers 人上过场，另有 $noAppearanceCount 人未上场；下次轮转可优先关注他们。';
  }
  if (appearanceSpread <= 1) {
    return '所有球友都上过场，最多与最少出场次数相差不超过 1 场。';
  }
  return '所有球友都上过场，最多与最少出场相差 $appearanceSpread 场；可回看轮转分布。';
}

final class _PlayerPerformance {
  const _PlayerPerformance({
    required this.name,
    required this.stats,
    required this.scoredMatches,
    required this.frequentPartnerName,
  });

  final String name;
  final PlayerStats stats;
  final int scoredMatches;
  final String? frequentPartnerName;

  bool get hasCompleteScores =>
      scoredMatches == stats.completedMatches && stats.completedMatches > 0;
}

class _SessionInsight extends StatelessWidget {
  const _SessionInsight({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: RallyPairColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: RallyPairColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({
    required this.matches,
    required this.participants,
    required this.players,
    required this.averageAppearances,
  });

  final int matches;
  final int participants;
  final int players;
  final double averageAppearances;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Metric(label: '完成比赛', value: '$matches 场'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Metric(label: '上场覆盖', value: '$participants / $players 人'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Metric(
            label: '人均出场',
            value: '${averageAppearances.toStringAsFixed(1)} 场',
          ),
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
            overflow: TextOverflow.fade,
            softWrap: false,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: RallyPairColors.textSecondary),
        ),
      ],
    );
  }
}

class _PlayerStatsRow extends StatelessWidget {
  const _PlayerStatsRow({required this.performance});

  final _PlayerPerformance performance;

  @override
  Widget build(BuildContext context) {
    final stats = performance.stats;
    final winRate = (stats.wins * 100 / stats.completedMatches).round();
    final netPoints = stats.pointsFor - stats.pointsAgainst;
    final detailParts = <String>[
      if (performance.frequentPartnerName case final partner?) '常搭档 $partner',
      if (performance.hasCompleteScores)
        '净胜分 ${netPoints > 0 ? '+' : ''}$netPoints',
    ];
    return Container(
      key: ValueKey('player-performance-${stats.playerId}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  performance.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '出场 ${stats.completedMatches} 场 · ${stats.wins} 胜 ${stats.losses} 负',
                  style: const TextStyle(color: RallyPairColors.textSecondary),
                ),
                if (detailParts.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    detailParts.join(' · '),
                    style: const TextStyle(
                      color: RallyPairColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$winRate%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: RallyPairColors.primary,
                ),
              ),
              const Text(
                '本场胜率',
                style: TextStyle(
                  color: RallyPairColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerformanceEmpty extends StatelessWidget {
  const _PerformanceEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: const Text(
        '没有完成的比赛，暂时无法生成球友表现。',
        textAlign: TextAlign.center,
        style: TextStyle(color: RallyPairColors.textSecondary),
      ),
    );
  }
}

class _NoAppearancePanel extends StatelessWidget {
  const _NoAppearancePanel({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RallyPairColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '未上场 ${names.length} 人',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            '这些球友没有产生比赛统计。',
            style: TextStyle(color: RallyPairColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final name in names)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: RallyPairColors.surface,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchHistory extends StatelessWidget {
  const _MatchHistory({
    required this.matches,
    required this.names,
    required this.showCourt,
    required this.busy,
    required this.onCorrect,
  });

  final List<SessionMatch> matches;
  final Map<int, String> names;
  final bool showCourt;
  final bool busy;
  final ValueChanged<SessionMatch> onCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyPairColors.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const ValueKey('match-history-expansion'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text('比赛记录', style: Theme.of(context).textTheme.titleLarge),
        subtitle: Text('${matches.length} 场 · 展开查看对阵、比分和修正'),
        children: [
          for (var index = 0; index < matches.length; index++) ...[
            _SummaryMatchCard(
              match: matches[index],
              names: names,
              showCourt: showCourt,
              busy: busy,
              onCorrect: () => onCorrect(matches[index]),
            ),
            if (index != matches.length - 1) const SizedBox(height: 8),
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
    required this.showCourt,
    required this.busy,
    required this.onCorrect,
  });

  final SessionMatch match;
  final Map<int, String> names;
  final bool showCourt;
  final bool busy;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final result = match.result!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: RallyPairColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showCourt
                      ? '${match.courtNumber} 号场 · 第 ${match.completedOrder} 场'
                      : '第 ${match.completedOrder} 场',
                  style: const TextStyle(color: RallyPairColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: busy ? null : onCorrect,
                child: const Text('修正结果'),
              ),
            ],
          ),
          _MatchTeamRow(
            name: _teamName(match.teamA, names),
            score: result.games.isEmpty
                ? null
                : result.games.map((game) => game.a).join(' / '),
            won: result.winner == Side.a,
          ),
          const SizedBox(height: 6),
          _MatchTeamRow(
            name: _teamName(match.teamB, names),
            score: result.games.isEmpty
                ? null
                : result.games.map((game) => game.b).join(' / '),
            won: result.winner == Side.b,
          ),
          if (result.games.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              '本场只记录胜方，未记录比分。',
              style: TextStyle(
                color: RallyPairColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _teamName(Team team, Map<int, String> names) {
  final first = names[team.first] ?? '未知球友';
  if (team.second case final second?) {
    return '$first · ${names[second] ?? '未知球友'}';
  }
  return first;
}

class _MatchTeamRow extends StatelessWidget {
  const _MatchTeamRow({
    required this.name,
    required this.score,
    required this.won,
  });

  final String name;
  final String? score;
  final bool won;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: won ? const Color(0xFFE9F0FF) : RallyPairColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: won ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          if (score case final value?) ...[
            const SizedBox(width: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          const SizedBox(width: 10),
          Text(
            won ? '胜' : '负',
            style: TextStyle(
              color: won
                  ? RallyPairColors.primary
                  : RallyPairColors.textSecondary,
              fontWeight: FontWeight.w800,
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
        '本场未产生有效比赛，也没有可查看的比赛记录。',
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
