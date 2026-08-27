part of 'live_session_page.dart';

class _WaitingPane extends StatelessWidget {
  const _WaitingPane({
    required this.session,
    required this.busy,
    required this.onAdd,
    required this.onBatchAdd,
    required this.onRest,
    required this.onReturn,
    required this.onLeave,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onAdd;
  final VoidCallback onBatchAdd;
  final ValueChanged<int> onRest;
  final ValueChanged<int> onReturn;
  final ValueChanged<int> onLeave;

  @override
  Widget build(BuildContext context) {
    final groups = <(String, PlayerState, List<SessionPlayer>)>[
      ('候场', PlayerState.waiting, session.waitingPlayers),
      (
        '休息',
        PlayerState.resting,
        session.players
            .where((player) => player.state == PlayerState.resting)
            .toList(),
      ),
      (
        '已离场',
        PlayerState.left,
        session.players
            .where((player) => player.state == PlayerState.left)
            .toList(),
      ),
      (
        '已分组',
        PlayerState.assigned,
        session.players
            .where((player) => player.state == PlayerState.assigned)
            .toList(),
      ),
      (
        '比赛中',
        PlayerState.playing,
        session.players
            .where((player) => player.state == PlayerState.playing)
            .toList(),
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(title: '玩家状态', description: '现场加入的新玩家会直接排到候场队列末尾。'),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                onPressed: busy ? null : onAdd,
                child: const Text('添加玩家'),
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
        for (final group in groups)
          if (group.$3.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '${group.$1} · ${group.$3.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (var index = 0; index < group.$3.length; index++) ...[
              _LivePlayerCard(
                player: group.$3[index],
                busy: busy,
                onRest: onRest,
                onReturn: onReturn,
                onLeave: onLeave,
              ),
              if (index != group.$3.length - 1) const SizedBox(height: 8),
            ],
          ],
      ],
    );
  }
}

class _LivePlayerCard extends StatelessWidget {
  const _LivePlayerCard({
    required this.player,
    required this.busy,
    required this.onRest,
    required this.onReturn,
    required this.onLeave,
  });

  final SessionPlayer player;
  final bool busy;
  final ValueChanged<int> onRest;
  final ValueChanged<int> onReturn;
  final ValueChanged<int> onLeave;

  @override
  Widget build(BuildContext context) {
    final editable =
        player.state == PlayerState.waiting ||
        player.state == PlayerState.resting ||
        player.state == PlayerState.left;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (!editable)
            Text(
              player.state == PlayerState.playing ? '比赛中' : '等待开赛',
              style: const TextStyle(color: RallyPairColors.textSecondary),
            )
          else
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 2,
                children: [
                  if (player.state == PlayerState.waiting)
                    TextButton(
                      onPressed: busy ? null : () => onRest(player.id),
                      child: const Text('休息'),
                    ),
                  if (player.state == PlayerState.resting ||
                      player.state == PlayerState.left)
                    TextButton(
                      onPressed: busy ? null : () => onReturn(player.id),
                      child: const Text('回到候场'),
                    ),
                  if (player.state == PlayerState.waiting ||
                      player.state == PlayerState.resting)
                    TextButton(
                      onPressed: busy ? null : () => onLeave(player.id),
                      style: TextButton.styleFrom(
                        foregroundColor: RallyPairColors.danger,
                      ),
                      child: const Text('离场'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
