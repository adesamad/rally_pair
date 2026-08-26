import 'package:flutter/material.dart';

import '../../rally_pair_widgets/rally_pair_icon/rally_pair_icon.dart';
import '../../rally_pair_widgets/rt_rally_pair_input/rt_rally_pair_input.dart';
import '../../zf_rally_pair_app/zf_rally_pair_app.dart';
import '../session_models.dart';
import '../session_store.dart';

class SessionSetupPage extends StatefulWidget {
  const SessionSetupPage({
    super.key,
    required this.session,
    required this.store,
  });

  final PlaySession session;
  final PlaySessionStore store;

  @override
  State<SessionSetupPage> createState() => _SessionSetupPageState();
}

class _SessionSetupPageState extends State<SessionSetupPage> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();
  late Stream<List<SessionPlayer>> _players;
  var _name = '';
  var _adding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _players = widget.store.watchPlayers(widget.session.id);
  }

  @override
  void didUpdateWidget(covariant SessionSetupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store == widget.store &&
        oldWidget.session.id == widget.session.id) {
      return;
    }
    _players = widget.store.watchPlayers(widget.session.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _addPlayer() async {
    if (_adding || _name.trim().isEmpty) return;
    setState(() {
      _adding = true;
      _error = null;
    });

    try {
      await widget.store.addPlayer(widget.session.id, _name);
      if (!mounted) return;
      _nameController.clear();
      _nameFocus.requestFocus();
      setState(() {
        _name = '';
        _adding = false;
        _players = widget.store.watchPlayers(widget.session.id);
      });
    } on SessionRuleException catch (error) {
      if (!mounted) return;
      setState(() {
        _adding = false;
        _error = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _adding = false;
        _error = '添加失败，请稍后重试';
      });
    }
  }

  Future<void> _removePlayer(SessionPlayer player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('移除${player.displayName}？'),
        content: const Text('确认后会从本场名单中删除，其他玩家不受影响。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('保留'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: ZfRallyPairColors.danger,
            ),
            child: const Text('确认移除'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      await widget.store.removePlayer(widget.session.id, player.id);
      if (!mounted) return;
      setState(() => _players = widget.store.watchPlayers(widget.session.id));
    } on SessionRuleException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = '移除失败，请稍后重试');
    }
  }

  void _retry() {
    setState(() => _players = widget.store.watchPlayers(widget.session.id));
  }

  void _onNameChanged(String value) {
    setState(() {
      _name = value;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<SessionPlayer>>(
          stream: _players,
          builder: (context, snapshot) {
            return CustomScrollView(
              key: const PageStorageKey('session-setup-scroll'),
              slivers: [
                SliverToBoxAdapter(
                  child: _SetupHeader(session: widget.session),
                ),
                SliverToBoxAdapter(
                  child: _SetupSummary(session: widget.session),
                ),
                SliverToBoxAdapter(
                  child: _RosterHeader(
                    count: snapshot.data?.length,
                    failed: snapshot.hasError,
                  ),
                ),
                ..._playerSlivers(snapshot),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _PlayerInput(
          controller: _nameController,
          focusNode: _nameFocus,
          adding: _adding,
          enabled: _name.trim().isNotEmpty,
          error: _error,
          onChanged: _onNameChanged,
          onAdd: _addPlayer,
        ),
      ),
    );
  }

  List<Widget> _playerSlivers(AsyncSnapshot<List<SessionPlayer>> snapshot) {
    if (snapshot.hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _RosterError(onRetry: _retry),
        ),
      ];
    }
    if (!snapshot.hasData) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final players = snapshot.data!;
    if (players.isEmpty) {
      return const [
        SliverFillRemaining(hasScrollBody: false, child: _EmptyRoster()),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        sliver: SliverList.builder(
          itemCount: players.length,
          itemBuilder: (context, index) {
            final player = players[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == players.length - 1 ? 0 : 10,
              ),
              child: _PlayerRow(
                player: player,
                number: index + 1,
                onRemove: () => _removePlayer(player),
              ),
            );
          },
        ),
      ),
    ];
  }
}

class _SetupHeader extends StatelessWidget {
  const _SetupHeader({required this.session});

  final PlaySession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            key: const Key('back-to-library'),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('返回球局列表'),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  '草稿 · 名单变更会自动保存在本机',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ZfRallyPairColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupSummary extends StatelessWidget {
  const _SetupSummary({required this.session});

  final PlaySession session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _SummaryItem(label: '场地', value: '${session.courtCount} 块'),
          _SummaryItem(label: '分组', value: session.pairingPolicy.label),
          _SummaryItem(label: '比分', value: session.scorePreset.label),
          _SummaryItem(
            label: '重复搭档',
            value: session.avoidRecentPartner ? '尽量避免' : '不限制',
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: ZfRallyPairColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZfRallyPairColors.surfaceSoft),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ZfRallyPairColors.textSecondary,
              ),
            ),
            TextSpan(text: value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _RosterHeader extends StatelessWidget {
  const _RosterHeader({required this.count, required this.failed});

  final int? count;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = switch (count) {
      _ when failed => '人数暂不可用',
      null => '正在读取名单',
      final current when current < 4 => '还差 ${4 - current} 人可组成一场双打',
      final current => '$current 人已到场',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('玩家名单', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            progress,
            key: const Key('roster-progress'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: ZfRallyPairColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoster extends StatelessWidget {
  const _EmptyRoster();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: ZfRallyPairColors.surface,
                shape: BoxShape.circle,
              ),
              child: const RallyPairIcon(
                RallyPairIconAsset.playerAdd,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text('还没有玩家', style: theme.textTheme.titleMedium),
            const SizedBox(height: 7),
            Text(
              '从下方添加到场玩家，保存后会出现在当前名单中。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ZfRallyPairColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.number,
    required this.onRemove,
  });

  final SessionPlayer player;
  final int number;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: ZfRallyPairColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZfRallyPairColors.surfaceSoft),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: ZfRallyPairColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: Text('$number', style: theme.textTheme.titleSmall),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                Text(
                  '候场',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ZfRallyPairColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            key: Key('remove-player-${player.id}'),
            onPressed: onRemove,
            style: TextButton.styleFrom(
              foregroundColor: ZfRallyPairColors.danger,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }
}

class _PlayerInput extends StatelessWidget {
  const _PlayerInput({
    required this.controller,
    required this.focusNode,
    required this.adding,
    required this.enabled,
    required this.error,
    required this.onChanged,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool adding;
  final bool enabled;
  final String? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: ZfRallyPairColors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: RtRallyPairInputField(
                    key: const Key('player-name'),
                    controller: controller,
                    focusNode: focusNode,
                    hintText: '输入玩家名称',
                    maxLength: 40,
                    borderRadius: 14,
                    backgroundColor: ZfRallyPairColors.background,
                    border: Border.all(color: ZfRallyPairColors.surfaceSoft),
                    onChanged: onChanged,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 104,
                  child: FilledButton.icon(
                    key: const Key('add-player'),
                    onPressed: enabled && !adding ? onAdd : null,
                    icon: const ExcludeSemantics(
                      child: RallyPairIcon(RallyPairIconAsset.playerAdd),
                    ),
                    label: Text(adding ? '添加中…' : '添加'),
                  ),
                ),
              ],
            ),
            if (error case final message?) ...[
              const SizedBox(height: 7),
              Text(
                message,
                key: const Key('player-error'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ZfRallyPairColors.danger,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RosterError extends StatelessWidget {
  const _RosterError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('暂时无法读取名单', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '已保存的玩家不会丢失，可以稍后重新读取。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ZfRallyPairColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onRetry, child: const Text('重新读取')),
          ],
        ),
      ),
    );
  }
}
