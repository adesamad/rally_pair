import 'package:flutter/material.dart';

import '../play_session/play_session.dart';
import '../rally_pair_icon.dart';
import '../rally_pair_theme.dart';
import 'player_input_dialogs.dart';
import 'rule_violation_message.dart';

part 'live_session_court_pane.dart';
part 'live_session_grouping_pane.dart';
part 'live_session_waiting_pane.dart';
part 'live_session_rotation_pane.dart';
part 'live_session_results_pane.dart';

class LiveSessionPage extends StatefulWidget {
  const LiveSessionPage({
    super.key,
    required this.store,
    required this.sessionId,
  });

  final PlaySessionStore store;
  final int sessionId;

  @override
  State<LiveSessionPage> createState() => _LiveSessionPageState();
}

class _LiveSessionPageState extends State<LiveSessionPage> {
  PlaySession? _session;
  Object? _error;
  var _loading = true;
  var _busy = false;
  var _destination = 0;

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
      if (session.status != SessionStatus.active) {
        throw const RuleViolation('session_not_active');
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

  Future<bool> _update(
    void Function(PlaySession session) change, {
    String? successMessage,
  }) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      final session = await widget.store.update(widget.sessionId, change);
      if (!mounted) return false;
      setState(() {
        _session = session;
        _busy = false;
      });
      if (successMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() => _busy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ruleViolationMessage(error))));
      return false;
    }
  }

  Future<void> _generate({required bool regenerate}) async {
    var count = 0;
    final succeeded = await _update((session) {
      count = regenerate
          ? session.regenerateReadyMatches().length
          : session.generateAssignments().length;
    });
    if (!mounted || !succeeded) return;
    final message = count == 0 ? '当前没有足够的候场玩家或空闲场地。' : '已生成 $count 场分组。';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addPlayer() async {
    final name = await showPlayerNameDialog(context, title: '现场添加玩家');
    if (!mounted || name == null) return;
    await _update(
      (session) => session.addPlayer(name),
      successMessage: '$name 已加入候场。',
    );
  }

  Future<void> _batchAdd() async {
    final names = await showBatchPlayerDialog(context);
    if (!mounted || names == null) return;
    BatchAddResult? result;
    final succeeded = await _update((session) {
      result = session.batchAddPlayers(names);
    });
    if (!mounted || !succeeded || result == null) return;
    final skipped = result!.skipped.length;
    final message = skipped == 0
        ? '已加入 ${result!.added.length} 名玩家。'
        : '已加入 ${result!.added.length} 名，跳过 $skipped 个重名。';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _recordWinner(SessionMatch match) async {
    final side = await showDialog<Side>(
      context: context,
      builder: (dialogContext) =>
          _WinnerDialog(match: match, names: _playerNames(_session!)),
    );
    if (!mounted || side == null) return;
    await _update(
      (session) => session.finishMatch(match.id, MatchResult.winnerOnly(side)),
      successMessage: '${match.courtNumber} 号场结果已记录。',
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.setup.title ?? '现场球局'),
        bottom: _busy
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      bottomNavigationBar: session == null || _loading || _error != null
          ? null
          : NavigationBar(
              selectedIndex: _destination,
              onDestinationSelected: (value) {
                setState(() => _destination = value);
              },
              destinations: const [
                NavigationDestination(
                  icon: RallyPairIcon(
                    RallyPairIconData.court,
                    semanticLabel: '球场',
                  ),
                  label: '球场',
                ),
                NavigationDestination(
                  icon: RallyPairIcon(
                    RallyPairIconData.grouping,
                    semanticLabel: '分组',
                  ),
                  label: '分组',
                ),
                NavigationDestination(
                  icon: RallyPairIcon(
                    RallyPairIconData.waitingQueue,
                    semanticLabel: '候场',
                  ),
                  label: '候场',
                ),
                NavigationDestination(
                  icon: RallyPairIcon(
                    RallyPairIconData.rotation,
                    semanticLabel: '轮转',
                  ),
                  label: '轮转',
                ),
                NavigationDestination(
                  icon: RallyPairIcon(
                    RallyPairIconData.result,
                    semanticLabel: '结果',
                  ),
                  label: '结果',
                ),
              ],
            ),
      body: SafeArea(
        top: false,
        child: switch ((_loading, _error, session)) {
          (true, _, _) => const Center(child: CircularProgressIndicator()),
          (false, final error?, _) => _LiveError(
            message: ruleViolationMessage(error),
            onRetry: _load,
          ),
          (false, null, final value?) => Column(
            children: [
              _SessionSummaryBand(session: value),
              Expanded(child: _buildDestination(value)),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Widget _buildDestination(PlaySession session) {
    return switch (_destination) {
      0 => _CourtPane(
        session: session,
        busy: _busy,
        onStart: (matchId) => _update(
          (value) => value.startMatch(matchId),
          successMessage: '比赛已开始。',
        ),
        onCancel: (matchId) => _update(
          (value) => value.cancelMatch(matchId),
          successMessage: '比赛已取消，玩家已回到候场。',
        ),
        onRecordWinner: _recordWinner,
      ),
      1 => _GroupingPane(
        session: session,
        busy: _busy,
        onGenerate: () => _generate(regenerate: false),
        onRegenerate: () => _generate(regenerate: true),
      ),
      2 => _WaitingPane(
        session: session,
        busy: _busy,
        onAdd: _addPlayer,
        onBatchAdd: _batchAdd,
        onRest: (playerId) => _update((value) => value.setResting(playerId)),
        onReturn: (playerId) =>
            _update((value) => value.restoreWaiting(playerId)),
        onLeave: (playerId) => _update((value) => value.setLeft(playerId)),
      ),
      3 => _RotationPane(session: session),
      _ => _ResultsPane(session: session),
    };
  }
}

Map<int, String> _playerNames(PlaySession session) => {
  for (final player in session.players) player.id: player.name,
};

String _teamName(Team team, Map<int, String> names) {
  return '${names[team.first] ?? '未知玩家'} · ${names[team.second] ?? '未知玩家'}';
}

class _SessionSummaryBand extends StatelessWidget {
  const _SessionSummaryBand({required this.session});

  final PlaySession session;

  @override
  Widget build(BuildContext context) {
    final activeMatches = session.matches
        .where((match) => match.state == MatchState.inProgress)
        .length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: RallyPairColors.surface,
        border: Border(bottom: BorderSide(color: RallyPairColors.outline)),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        children: [
          _SummaryValue(
            label: '候场',
            value: '${session.waitingPlayers.length} 人',
          ),
          _SummaryValue(label: '比赛中', value: '$activeMatches 场'),
          _SummaryValue(label: '场地', value: '${session.setup.courtCount} 块'),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label ',
        style: const TextStyle(color: RallyPairColors.textSecondary),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: RallyPairColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(color: RallyPairColors.textSecondary),
        ),
      ],
    );
  }
}

class _SimpleEmpty extends StatelessWidget {
  const _SimpleEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: RallyPairColors.textSecondary),
      ),
    );
  }
}

class _LiveError extends StatelessWidget {
  const _LiveError({required this.message, required this.onRetry});

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
