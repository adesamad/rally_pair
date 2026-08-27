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

  Future<void> _manualGroup() async {
    final session = _session;
    if (session == null) return;
    final players = session.players
        .where((player) => player.state == PlayerState.ungrouped)
        .toList(growable: false);
    if (players.length < 2) return;
    final selected = await showManualGroupDialog(context, players);
    if (!mounted || selected == null) return;
    await _update((value) => value.createManualGroup(selected.$1, selected.$2));
  }

  Future<void> _replaceGroupPlayer(PairingGroup group) async {
    final session = _session;
    if (session == null) return;
    final current = session.players
        .where((player) => group.contains(player.id))
        .toList(growable: false);
    final replacements = session.players
        .where((player) => player.state == PlayerState.ungrouped)
        .toList(growable: false);
    final selected = await showGroupMemberReplacementDialog(
      context,
      group: group,
      currentPlayers: current,
      replacements: replacements,
    );
    if (!mounted || selected == null) return;
    await _update(
      (value) => value.updateGroup(
        groupId: group.id,
        sourcePlayerId: selected.$1,
        replacementPlayerId: selected.$2,
      ),
    );
  }

  Future<void> _assignSpecificGroups() async {
    final session = _session;
    if (session == null) return;
    final courts = session.courts
        .where((court) => court.state == CourtState.available)
        .toList(growable: false);
    final groups = session.waitingGroups;
    if (courts.isEmpty || groups.length < 2) return;
    var courtNumber = courts.first.number;
    var firstGroupId = groups.first.id;
    var secondGroupId = groups[1].id;
    final names = _playerNames(session);
    final selected = await showDialog<(int, int, int)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('手动安排上场'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: courtNumber,
                decoration: const InputDecoration(labelText: '场地'),
                items: [
                  for (final court in courts)
                    DropdownMenuItem(
                      value: court.number,
                      child: Text(court.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => courtNumber = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: firstGroupId,
                decoration: const InputDecoration(labelText: '第一组'),
                items: [
                  for (final group in groups)
                    DropdownMenuItem(
                      value: group.id,
                      child: Text(
                        '${names[group.firstPlayerId]} · ${names[group.secondPlayerId]}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => firstGroupId = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: secondGroupId,
                decoration: const InputDecoration(labelText: '第二组'),
                items: [
                  for (final group in groups)
                    DropdownMenuItem(
                      value: group.id,
                      child: Text(
                        '${names[group.firstPlayerId]} · ${names[group.secondPlayerId]}',
                      ),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => secondGroupId = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: firstGroupId == secondGroupId
                  ? null
                  : () => Navigator.of(
                      dialogContext,
                    ).pop((courtNumber, firstGroupId, secondGroupId)),
              child: const Text('安排到场地'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _update(
      (value) => value.assignGroups(
        courtNumber: selected.$1,
        firstGroupId: selected.$2,
        secondGroupId: selected.$3,
      ),
    );
  }

  Future<void> _renamePlayer(SessionPlayer player) async {
    final name = await showPlayerNameDialog(
      context,
      title: '修改玩家名称',
      initialValue: player.name,
      confirmLabel: '保存',
    );
    if (!mounted || name == null || name == player.name) return;
    await _update((value) => value.renamePlayer(player.id, name));
  }

  Future<void> _removePlayer(SessionPlayer player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除玩家？'),
        content: Text('仅未成组且没有比赛历史的玩家可以移除。\n\n${player.name}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _update((value) => value.removePlayer(player.id));
  }

  Future<void> _recordWinner(SessionMatch match) async {
    final result = await showDialog<MatchResult>(
      context: context,
      builder: (dialogContext) => _WinnerDialog(
        match: match,
        names: _playerNames(_session!),
        scorePreset: _session!.setup.scorePreset,
      ),
    );
    if (!mounted || result == null) return;
    final saved = await _update(
      (session) => session.finishMatch(match.id, result),
      successMessage: '${match.courtNumber} 号场结果已记录。',
    );
    if (!mounted || !saved) return;
    await _chooseRotation(
      _session!.matches.firstWhere((m) => m.id == match.id),
    );
  }

  Future<void> _chooseRotation(SessionMatch match) async {
    final mode = await showDialog<RotationMode>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('这一场怎么上下场？'),
        content: const Text('选择后会立即更新这块场地和候场顺序。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('稍后决定'),
          ),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(RotationMode.allRotate),
            child: const Text('两组下场'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(RotationMode.winnerStays),
            child: const Text('胜方留场'),
          ),
        ],
      ),
    );
    if (!mounted || mode == null) return;
    await _update((session) {
      if (mode == RotationMode.winnerStays) {
        session.resolveWinnerStays(match.id);
      } else {
        session.resolveAllRotate(match.id);
      }
    });
  }

  Future<void> _correctResult(SessionMatch match) async {
    final result = await showDialog<MatchResult>(
      context: context,
      builder: (dialogContext) => _WinnerDialog(
        match: match,
        names: _playerNames(_session!),
        scorePreset: _session!.setup.scorePreset,
      ),
    );
    if (!mounted || result == null) return;
    await _update(
      (session) => session.correctMatch(match.id, result),
      successMessage: '历史比赛结果已修正，统计已重新计算。',
    );
  }

  Future<void> _completeSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束本场球局？'),
        content: const Text('只有全部场地已空闲、没有待开赛或待轮转比赛时才能结束。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('继续比赛'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('结束球局'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final completed = await _update((session) => session.complete());
    if (!mounted || !completed) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.setup.title ?? '现场球局'),
        actions: [
          TextButton(
            key: const ValueKey('complete-session'),
            onPressed: session == null || _busy ? null : _completeSession,
            child: const Text('结束球局'),
          ),
          const SizedBox(width: 8),
        ],
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
        onRotate: _chooseRotation,
        onFill: (courtNumber) =>
            _update((value) => value.fillStayingCourt(courtNumber)),
        onRelease: (courtNumber) =>
            _update((value) => value.releaseStayingCourt(courtNumber)),
        onRemoveCourt: (courtNumber) =>
            _update((value) => value.removeCourt(courtNumber)),
      ),
      1 => _GroupingPane(
        session: session,
        busy: _busy,
        onGenerate: () => _generate(regenerate: false),
        onRegenerate: () => _generate(regenerate: true),
        onRandomGroups: () => _update((value) => value.generateRandomGroups()),
        onManualGroup: _manualGroup,
        onReplaceGroupPlayer: _replaceGroupPlayer,
        onDissolveGroup: (group) =>
            _update((value) => value.dissolveGroup(group.id)),
        onAssignSpecific: _assignSpecificGroups,
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
        onRename: _renamePlayer,
        onRemove: _removePlayer,
      ),
      3 => _RotationPane(
        session: session,
        busy: _busy,
        onRandomize: () => _update((value) => value.randomizeGroupQueue()),
        onMove: (groupId, targetIndex) =>
            _update((value) => value.reorderGroup(groupId, targetIndex)),
      ),
      _ => _ResultsPane(session: session, onCorrect: _correctResult),
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
            value: '${session.waitingGroups.length} 组',
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
