import 'package:flutter/material.dart';

import '../play_session/play_session.dart';
import '../rally_pair_icon.dart';
import '../rally_pair_theme.dart';
import 'live_session_page.dart';
import 'player_input_dialogs.dart';
import 'rule_violation_message.dart';

class SessionRosterPage extends StatefulWidget {
  const SessionRosterPage({
    super.key,
    required this.store,
    required this.sessionId,
  });

  final PlaySessionStore store;
  final int sessionId;

  @override
  State<SessionRosterPage> createState() => _SessionRosterPageState();
}

class _SessionRosterPageState extends State<SessionRosterPage> {
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

  Future<bool> _update(void Function(PlaySession session) change) async {
    if (_busy) return false;
    setState(() => _busy = true);
    try {
      final session = await widget.store.update(widget.sessionId, change);
      if (!mounted) return false;
      setState(() {
        _session = session;
        _busy = false;
      });
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

  Future<void> _addPlayer() async {
    final name = await showPlayerNameDialog(context, title: '添加玩家');
    if (!mounted || name == null) return;
    await _update((session) => session.addPlayer(name));
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

  Future<void> _renamePlayer(SessionPlayer player) async {
    final name = await showPlayerNameDialog(
      context,
      title: '修改玩家名称',
      initialValue: player.name,
      confirmLabel: '保存',
    );
    if (!mounted || name == null || name == player.name) return;
    await _update((session) => session.renamePlayer(player.id, name));
  }

  Future<void> _removePlayer(SessionPlayer player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移除玩家？'),
        content: Text('将 ${player.name} 从本场名单中移除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: RallyPairColors.danger,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _update((session) => session.removePlayer(player.id));
  }

  Future<void> _startOrEnter() async {
    final session = _session;
    if (session == null) return;
    if (session.status == SessionStatus.draft) {
      final succeeded = await _update((value) => value.start());
      if (!mounted || !succeeded) return;
    }
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(
        builder: (_) =>
            LiveSessionPage(store: widget.store, sessionId: widget.sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(title: Text(session?.setup.title ?? '玩家名单')),
      bottomNavigationBar: session == null || _loading || _error != null
          ? null
          : _RosterBottomAction(
              session: session,
              busy: _busy,
              onPressed: _startOrEnter,
            ),
      body: SafeArea(
        top: false,
        child: switch ((_loading, _error, session)) {
          (true, _, _) => const Center(child: CircularProgressIndicator()),
          (false, final error?, _) => _RosterError(
            message: ruleViolationMessage(error),
            onRetry: _load,
          ),
          (false, null, final value?) => _RosterContent(
            session: value,
            busy: _busy,
            onAdd: _addPlayer,
            onBatchAdd: _batchAdd,
            onRename: _renamePlayer,
            onRemove: _removePlayer,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _RosterContent extends StatelessWidget {
  const _RosterContent({
    required this.session,
    required this.busy,
    required this.onAdd,
    required this.onBatchAdd,
    required this.onRename,
    required this.onRemove,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onBatchAdd;
  final ValueChanged<SessionPlayer> onRename;
  final ValueChanged<SessionPlayer> onRemove;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '准备本场玩家',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  session.players.length < 4
                      ? '至少加入 4 名玩家后才能启动球局。'
                      : '名单已满足开局人数，还可以继续添加或调整。',
                  style: const TextStyle(color: RallyPairColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: busy ? null : onAdd,
                        child: const _IconButtonLabel(
                          icon: RallyPairIconData.playerAdd,
                          label: '添加玩家',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: busy ? null : onBatchAdd,
                        child: const Text('批量添加'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text('本场名单', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '${session.players.length} 人',
                      style: const TextStyle(
                        color: RallyPairColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (session.players.isEmpty)
                  const _RosterEmpty()
                else
                  for (
                    var index = 0;
                    index < session.players.length;
                    index++
                  ) ...[
                    _PlayerCard(
                      index: index + 1,
                      player: session.players[index],
                      busy: busy,
                      onRename: () => onRename(session.players[index]),
                      onRemove: () => onRemove(session.players[index]),
                    ),
                    if (index != session.players.length - 1)
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

class _IconButtonLabel extends StatelessWidget {
  const _IconButtonLabel({required this.icon, required this.label});

  final RallyPairIconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RallyPairIcon(icon, semanticLabel: label),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

class _RosterEmpty extends StatelessWidget {
  const _RosterEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: const Column(
        children: [
          RallyPairIcon(
            RallyPairIconData.playerAdd,
            size: 32,
            semanticLabel: '添加第一名玩家',
          ),
          SizedBox(height: 14),
          Text('名单还是空的', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text(
            '可以逐个添加，也可以直接粘贴整份名单。',
            textAlign: TextAlign.center,
            style: TextStyle(color: RallyPairColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.index,
    required this.player,
    required this.busy,
    required this.onRename,
    required this.onRemove,
  });

  final int index;
  final SessionPlayer player;
  final bool busy;
  final VoidCallback onRename;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: RallyPairColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: RallyPairColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: busy ? null : onRename,
            child: const Text('改名'),
          ),
          TextButton(
            onPressed: busy ? null : onRemove,
            style: TextButton.styleFrom(
              foregroundColor: RallyPairColors.danger,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }
}

class _RosterBottomAction extends StatelessWidget {
  const _RosterBottomAction({
    required this.session,
    required this.busy,
    required this.onPressed,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final missing = 4 - session.waitingPlayers.length;
    final active = session.status == SessionStatus.active;
    final enabled = !busy && (active || missing <= 0);
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        decoration: const BoxDecoration(
          color: RallyPairColors.background,
          border: Border(top: BorderSide(color: RallyPairColors.outline)),
        ),
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          child: Text(
            busy
                ? '正在保存…'
                : active
                ? '进入现场球局'
                : missing > 0
                ? '还需 $missing 名玩家'
                : '启动球局',
          ),
        ),
      ),
    );
  }
}

class _RosterError extends StatelessWidget {
  const _RosterError({required this.message, required this.onRetry});

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
