import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  Future<void> _assignSpecificGroups([int? initialCourtNumber]) async {
    final session = _session;
    if (session == null) return;
    if (session.setup.matchFormat == MatchFormat.singles) {
      await _assignSpecificPlayers(initialCourtNumber);
      return;
    }
    final courts = session.courts
        .where((court) => court.state == CourtState.available)
        .toList(growable: false);
    final groups = session.waitingGroups;
    if (courts.isEmpty || groups.length < 2) return;
    var courtNumber = courts.any((court) => court.number == initialCourtNumber)
        ? initialCourtNumber!
        : courts.first.number;
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
              if (courts.length > 1) ...[
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
              ],
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
    final succeeded = await _update(
      (value) => value.assignGroups(
        courtNumber: selected.$1,
        firstGroupId: selected.$2,
        secondGroupId: selected.$3,
      ),
    );
    if (!mounted || !succeeded) return;
  }

  Future<void> _assignSpecificPlayers([int? initialCourtNumber]) async {
    final session = _session;
    if (session == null) return;
    final courts = session.courts
        .where((court) => court.state == CourtState.available)
        .toList(growable: false);
    final players = session.waitingPlayers;
    if (courts.isEmpty || players.length < 2) return;
    var courtNumber = courts.any((court) => court.number == initialCourtNumber)
        ? initialCourtNumber!
        : courts.first.number;
    var firstPlayerId = players.first.id;
    var secondPlayerId = players[1].id;
    final selected = await showDialog<(int, int, int)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('手动安排单打'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (courts.length > 1) ...[
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
              ],
              DropdownButtonFormField<int>(
                initialValue: firstPlayerId,
                decoration: const InputDecoration(labelText: 'A 方'),
                items: [
                  for (final player in players)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text(player.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => firstPlayerId = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: secondPlayerId,
                decoration: const InputDecoration(labelText: 'B 方'),
                items: [
                  for (final player in players)
                    DropdownMenuItem(
                      value: player.id,
                      child: Text(player.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => secondPlayerId = value);
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
              onPressed: firstPlayerId == secondPlayerId
                  ? null
                  : () => Navigator.of(
                      dialogContext,
                    ).pop((courtNumber, firstPlayerId, secondPlayerId)),
              child: const Text('安排上场'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    final succeeded = await _update(
      (value) => value.assignPlayers(
        courtNumber: selected.$1,
        firstPlayerId: selected.$2,
        secondPlayerId: selected.$3,
      ),
    );
    if (!mounted || !succeeded) return;
  }

  Future<void> _assignNext(int courtNumber) async {
    final singleCourt = _session?.courts.length == 1;
    final succeeded = await _update(
      (session) => session.assignNext(courtNumber),
      successMessage: singleCourt ? '下一场已经排好。' : '$courtNumber 号场已安排对阵。',
    );
    if (!mounted || !succeeded) return;
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

  Future<void> _finishMatch(SessionMatch match) async {
    final result = await showMatchFinishDialog(
      context,
      match: match,
      names: _playerNames(_session!),
      scorePreset: _session!.setup.scorePreset,
      defaultRotationMode: _session!.setup.defaultRotationMode,
      singles: _session!.setup.matchFormat == MatchFormat.singles,
    );
    if (!mounted || result == null) return;
    final saved = await _update(
      (session) => session.finishAndRotate(match.id, result),
    );
    if (!mounted || !saved) return;
    final nextReady = _session!.matches.any(
      (value) => value.state == MatchState.ready,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(nextReady ? '本场已完成，下一场已经排好。' : '本场已完成，候场顺序已更新。')),
    );
  }

  Future<void> _resolveRecorded(SessionMatch match) async {
    await _update(
      (session) => session.applyRotation(match.id),
      successMessage: '已按本场球局规则完成轮换。',
    );
  }

  Future<void> _correctResult(SessionMatch match) async {
    final result = await showMatchResultDialog(
      context,
      match: match,
      names: _playerNames(_session!),
      scorePreset: _session!.setup.scorePreset,
    );
    if (!mounted || result == null) return;
    await _update(
      (session) => session.correctMatch(match.id, result),
      successMessage: '历史比赛结果已修正，统计已重新计算。',
    );
  }

  Future<void> _completeSession() async {
    final hasUnfinished = _session!.matches.any(
      (match) =>
          match.state == MatchState.ready ||
          match.state == MatchState.inProgress ||
          match.state == MatchState.resultRecorded,
    );
    final hasStaying = _session!.courts.any(
      (court) => court.state == CourtState.waitingOpponent,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('结束本场球局？'),
        content: Text(
          hasUnfinished || hasStaying
              ? '当前未完成的比赛会取消，已记录结果会保留，留场球友会回到候场。结束后将生成本场总结。'
              : '结束后将冻结本场记录并生成总结。',
        ),
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
    final completed = await _update((session) => session.end());
    if (!mounted || !completed) return;
    Navigator.of(context).pop();
  }

  Future<void> _openTool(_LiveTool tool) async {
    var peopleSection = 0;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final session = _session;
          if (session == null) return const SizedBox.shrink();

          Future<void> refresh(Future<void> Function() action) async {
            await action();
            if (sheetContext.mounted) setSheetState(() {});
          }

          final content = switch (tool) {
            _LiveTool.people =>
              session.setup.matchFormat == MatchFormat.singles
                  ? _WaitingPane(
                      session: session,
                      busy: _busy,
                      onAdd: () => refresh(_addPlayer),
                      onBatchAdd: () => refresh(_batchAdd),
                      onRest: (playerId) => refresh(
                        () async =>
                            _update((value) => value.setResting(playerId)),
                      ),
                      onReturn: (playerId) => refresh(
                        () async =>
                            _update((value) => value.restoreWaiting(playerId)),
                      ),
                      onLeave: (playerId) => refresh(
                        () async => _update((value) => value.setLeft(playerId)),
                      ),
                      onRename: (player) =>
                          refresh(() => _renamePlayer(player)),
                      onRemove: (player) =>
                          refresh(() => _removePlayer(player)),
                    )
                  : Column(
                      children: [
                        _WorkspaceSwitch(
                          selected: peopleSection,
                          firstLabel: '双人组',
                          secondLabel: '球友状态',
                          onChanged: (value) {
                            setSheetState(() => peopleSection = value);
                          },
                        ),
                        Expanded(
                          child: peopleSection == 0
                              ? _GroupingPane(
                                  session: session,
                                  busy: _busy,
                                  onRandomGroups: () => refresh(
                                    () async => _update(
                                      (value) => value.generateRandomGroups(),
                                    ),
                                  ),
                                  onManualGroup: () => refresh(_manualGroup),
                                  onReplaceGroupPlayer: (group) =>
                                      refresh(() => _replaceGroupPlayer(group)),
                                  onDissolveGroup: (group) => refresh(
                                    () async => _update(
                                      (value) => value.dissolveGroup(group.id),
                                    ),
                                  ),
                                )
                              : _WaitingPane(
                                  session: session,
                                  busy: _busy,
                                  onAdd: () => refresh(_addPlayer),
                                  onBatchAdd: () => refresh(_batchAdd),
                                  onRest: (playerId) => refresh(
                                    () async => _update(
                                      (value) => value.setResting(playerId),
                                    ),
                                  ),
                                  onReturn: (playerId) => refresh(
                                    () async => _update(
                                      (value) => value.restoreWaiting(playerId),
                                    ),
                                  ),
                                  onLeave: (playerId) => refresh(
                                    () async => _update(
                                      (value) => value.setLeft(playerId),
                                    ),
                                  ),
                                  onRename: (player) =>
                                      refresh(() => _renamePlayer(player)),
                                  onRemove: (player) =>
                                      refresh(() => _removePlayer(player)),
                                ),
                        ),
                      ],
                    ),
            _LiveTool.queue => _RotationPane(
              session: session,
              busy: _busy,
              onRandomize: () => refresh(
                () async => _update(
                  (value) => value.setup.matchFormat == MatchFormat.singles
                      ? value.randomizePlayerQueue()
                      : value.randomizeGroupQueue(),
                ),
              ),
              onMove: (id, targetIndex) => refresh(
                () async => _update(
                  (value) => value.setup.matchFormat == MatchFormat.singles
                      ? value.reorderPlayer(id, targetIndex)
                      : value.reorderGroup(id, targetIndex),
                ),
              ),
            ),
            _LiveTool.results => _ResultsPane(
              session: session,
              onCorrect: (match) => refresh(() => _correctResult(match)),
            ),
          };
          return FractionallySizedBox(
            heightFactor: .92,
            child: Column(
              children: [
                _ToolHeader(
                  title: switch (tool) {
                    _LiveTool.people => '球友与组队',
                    _LiveTool.queue => '候场顺序',
                    _LiveTool.results => '比赛记录',
                  },
                  onClose: () => Navigator.of(sheetContext).pop(),
                ),
                Expanded(child: content),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(
        title: Text(session?.setup.title ?? '现场球局'),
        actions: [
          PopupMenuButton<String>(
            key: const ValueKey('complete-session'),
            tooltip: '球局操作',
            enabled: session != null && !_busy,
            onSelected: (value) {
              if (value == 'complete') _completeSession();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'complete', child: Text('结束球局')),
            ],
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
              _LiveToolsBar(
                onPeople: () => _openTool(_LiveTool.people),
                onQueue: () => _openTool(_LiveTool.queue),
                onResults: () => _openTool(_LiveTool.results),
              ),
              _NextActionCard(
                session: value,
                busy: _busy,
                onStart: (matchId) => _update(
                  (session) => session.startMatch(matchId),
                  successMessage: '比赛已开始。',
                ),
                onFinish: _finishMatch,
                onRotate: _resolveRecorded,
                onFill: (courtNumber) =>
                    _update((session) => session.fillStayingCourt(courtNumber)),
                onAssign: _assignNext,
                onOpenPeople: () => _openTool(_LiveTool.people),
              ),
              Expanded(
                child: _CourtPane(
                  session: value,
                  busy: _busy,
                  onGenerate: () => _generate(regenerate: false),
                  onRegenerate: () => _generate(regenerate: true),
                  onStart: (matchId) => _update(
                    (session) => session.startMatch(matchId),
                    successMessage: '比赛已开始。',
                  ),
                  onCancel: (matchId) => _update(
                    (value) => value.cancelMatch(matchId),
                    successMessage: '比赛已取消，球友已回到候场。',
                  ),
                  onRecordWinner: _finishMatch,
                  onRotate: _resolveRecorded,
                  onFill: (courtNumber) => _update(
                    (session) => session.fillStayingCourt(courtNumber),
                  ),
                  onRelease: (courtNumber) => _update(
                    (session) => session.releaseStayingCourt(courtNumber),
                  ),
                  onAssignNext: _assignNext,
                  onAssignSpecific: _assignSpecificGroups,
                  onRemoveCourt: (courtNumber) =>
                      _update((session) => session.removeCourt(courtNumber)),
                ),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

enum _LiveTool { people, queue, results }

class _LiveToolsBar extends StatelessWidget {
  const _LiveToolsBar({
    required this.onPeople,
    required this.onQueue,
    required this.onResults,
  });

  final VoidCallback onPeople;
  final VoidCallback onQueue;
  final VoidCallback onResults;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('live-tool-people'),
              onPressed: onPeople,
              child: const Text('球友'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('live-tool-queue'),
              onPressed: onQueue,
              child: const Text('候场顺序'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              key: const ValueKey('live-tool-results'),
              onPressed: onResults,
              child: const Text('比赛记录'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolHeader extends StatelessWidget {
  const _ToolHeader({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          IconButton(
            tooltip: '关闭',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

Map<int, String> _playerNames(PlaySession session) => {
  for (final player in session.players) player.id: player.name,
};

Future<MatchResult?> showMatchResultDialog(
  BuildContext context, {
  required SessionMatch match,
  required Map<int, String> names,
  required ScorePreset scorePreset,
}) {
  return showDialog<MatchResult>(
    context: context,
    builder: (_) =>
        _WinnerDialog(match: match, names: names, scorePreset: scorePreset),
  );
}

Future<MatchResult?> showMatchFinishDialog(
  BuildContext context, {
  required SessionMatch match,
  required Map<int, String> names,
  required ScorePreset scorePreset,
  required RotationMode defaultRotationMode,
  required bool singles,
}) {
  return showDialog<MatchResult>(
    context: context,
    builder: (_) => _FinishMatchDialog(
      match: match,
      names: names,
      scorePreset: scorePreset,
      defaultRotationMode: defaultRotationMode,
      singles: singles,
    ),
  );
}

String _teamName(Team team, Map<int, String> names) {
  final first = names[team.first] ?? '未知玩家';
  final second = team.second;
  return second == null ? first : '$first · ${names[second] ?? '未知玩家'}';
}

class _NextActionCard extends StatelessWidget {
  const _NextActionCard({
    required this.session,
    required this.busy,
    required this.onStart,
    required this.onFinish,
    required this.onRotate,
    required this.onFill,
    required this.onAssign,
    required this.onOpenPeople,
  });

  final PlaySession session;
  final bool busy;
  final Future<bool> Function(int matchId) onStart;
  final ValueChanged<SessionMatch> onFinish;
  final ValueChanged<SessionMatch> onRotate;
  final ValueChanged<int> onFill;
  final ValueChanged<int> onAssign;
  final VoidCallback onOpenPeople;

  @override
  Widget build(BuildContext context) {
    final recorded = session.matches
        .where((match) => match.state == MatchState.resultRecorded)
        .firstOrNull;
    final ready = session.matches
        .where((match) => match.state == MatchState.ready)
        .firstOrNull;
    final inProgress = session.matches
        .where((match) => match.state == MatchState.inProgress)
        .firstOrNull;
    final waitingCourt = session.courts
        .where((court) => court.state == CourtState.waitingOpponent)
        .firstOrNull;
    final availableCourt = session.courts
        .where((court) => court.state == CourtState.available)
        .firstOrNull;
    final ungrouped = session.players
        .where((player) => player.state == PlayerState.ungrouped)
        .length;
    final singles = session.setup.matchFormat == MatchFormat.singles;
    final waitingCount = singles
        ? session.waitingPlayers.length
        : session.waitingGroups.length;
    String matchLabel(SessionMatch match) =>
        session.courts.length == 1 ? '当前比赛' : '${match.courtNumber} 号场';
    String courtLabel(Court court) =>
        session.courts.length == 1 ? '当前球场' : '${court.number} 号场';

    late final String title;
    late final String description;
    String? actionLabel;
    VoidCallback? action;

    if (recorded != null) {
      title = '${matchLabel(recorded)}已记录结果';
      description = '结果已保存，可以按本场球局规则继续安排下一场。';
      actionLabel = '按规则继续';
      action = () => onRotate(recorded);
    } else if (inProgress != null) {
      title = '${matchLabel(inProgress)}正在进行';
      description = '比赛结束后，在这里一次完成结果和上下场。';
      actionLabel = '结束本场';
      action = () => onFinish(inProgress);
    } else if (ready != null) {
      title = '${matchLabel(ready)}已排好对阵';
      description = singles ? '两名球友已到位，确认后开始单打。' : '两组球友已到位，确认后开始双打。';
      actionLabel = '开始比赛';
      action = () => onStart(ready.id);
    } else if (waitingCourt != null) {
      title = '${courtLabel(waitingCourt)}正在等待对手';
      if (waitingCount > 0) {
        description = singles ? '已有候场球友，可以直接补入开始下一场。' : '已有候场组，可以直接补入开始下一场。';
        actionLabel = singles ? '补入下一人' : '补入下一组';
        action = () => onFill(waitingCourt.number);
      } else {
        description = '目前没有候场组，可先添加球友或完成组队。';
        actionLabel = '去管理球友';
        action = onOpenPeople;
      }
    } else if (availableCourt != null && waitingCount >= 2) {
      title = '${courtLabel(availableCourt)}可以安排下一场';
      description = singles ? '将按当前候场顺序取前两名球友进入场地。' : '将按当前候场顺序取队首两组进入场地。';
      actionLabel = '按顺序安排';
      action = () => onAssign(availableCourt.number);
    } else if (!singles && ungrouped >= 2) {
      title = '还有 $ungrouped 名球友未成组';
      description = '先组成固定双人组，他们才会进入候场顺序。';
      actionLabel = '去完成组队';
      action = onOpenPeople;
    } else {
      title = '现场暂无待处理动作';
      description = '可以检查球友和候场情况，或结束本场球局。';
    }

    return Container(
      key: const ValueKey('live-next-action'),
      margin: const EdgeInsets.fromLTRB(24, 14, 24, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyPairColors.primary, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '下一步',
                  style: TextStyle(
                    color: RallyPairColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: RallyPairColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            FilledButton.tonal(
              key: const ValueKey('live-next-action-button'),
              onPressed: busy ? null : action,
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceSwitch extends StatelessWidget {
  const _WorkspaceSwitch({
    required this.selected,
    required this.firstLabel,
    required this.secondLabel,
    required this.onChanged,
  });

  final int selected;
  final String firstLabel;
  final String secondLabel;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: 0, label: Text(firstLabel)),
            ButtonSegment(value: 1, label: Text(secondLabel)),
          ],
          selected: {selected},
          onSelectionChanged: (value) => onChanged(value.single),
        ),
      ),
    );
  }
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
            value: session.setup.matchFormat == MatchFormat.singles
                ? '${session.waitingPlayers.length} 人'
                : '${session.waitingGroups.length} 组',
          ),
          _SummaryValue(label: '比赛中', value: '$activeMatches 场'),
          _SummaryValue(
            label: '赛制',
            value: session.setup.matchFormat == MatchFormat.singles
                ? '单打 · 1 局'
                : '双打 · 1 局',
          ),
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
