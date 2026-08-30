part of 'live_session_page.dart';

class _RotationPane extends StatelessWidget {
  const _RotationPane({
    required this.session,
    required this.busy,
    required this.onRandomize,
    required this.onMove,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onRandomize;
  final void Function(int groupId, int targetIndex) onMove;

  @override
  Widget build(BuildContext context) {
    if (session.setup.matchFormat == MatchFormat.singles) {
      final players = session.waitingPlayers;
      return ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          const _SectionIntro(
            title: '上场顺序',
            description: '这里只调整候场球友；场上、待轮转和留场球友不会被移动。',
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            key: const ValueKey('randomize-player-queue'),
            onPressed: busy || players.length < 2 ? null : onRandomize,
            child: const Text('随机打乱顺序'),
          ),
          const SizedBox(height: 24),
          Text('当前候场顺序', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (players.isEmpty)
            const _SimpleEmpty(message: '现在没有候场球友。')
          else
            for (var index = 0; index < players.length; index++) ...[
              _PlayerQueueRow(
                position: index + 1,
                player: players[index],
                busy: busy,
                onUp: index == 0
                    ? null
                    : () => onMove(players[index].id, index - 1),
                onDown: index == players.length - 1
                    ? null
                    : () => onMove(players[index].id, index + 1),
              ),
              if (index != players.length - 1) const SizedBox(height: 8),
            ],
        ],
      );
    }
    final groups = session.waitingGroups;
    final names = _playerNames(session);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(
          title: '上场顺序',
          description: '这里只调整候场组；场上、待轮转和留场组不会被移动。',
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          key: const ValueKey('randomize-group-queue'),
          onPressed: busy || groups.length < 2 ? null : onRandomize,
          child: const Text('随机打乱顺序'),
        ),
        const SizedBox(height: 24),
        Text('当前候场顺序', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          const _SimpleEmpty(message: '现在没有候场组。')
        else
          for (var index = 0; index < groups.length; index++) ...[
            _GroupQueueRow(
              position: index + 1,
              group: groups[index],
              names: names,
              busy: busy,
              onUp: index == 0
                  ? null
                  : () => onMove(groups[index].id, index - 1),
              onDown: index == groups.length - 1
                  ? null
                  : () => onMove(groups[index].id, index + 1),
            ),
            if (index != groups.length - 1) const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _PlayerQueueRow extends StatelessWidget {
  const _PlayerQueueRow({
    required this.position,
    required this.player,
    required this.busy,
    required this.onUp,
    required this.onDown,
  });

  final int position;
  final SessionPlayer player;
  final bool busy;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Text(
            '$position',
            style: const TextStyle(
              color: RallyPairColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: '上移',
            onPressed: busy ? null : onUp,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton(
            tooltip: '下移',
            onPressed: busy ? null : onDown,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}

class _GroupQueueRow extends StatelessWidget {
  const _GroupQueueRow({
    required this.position,
    required this.group,
    required this.names,
    required this.busy,
    required this.onUp,
    required this.onDown,
  });

  final int position;
  final PairingGroup group;
  final Map<int, String> names;
  final bool busy;
  final VoidCallback? onUp;
  final VoidCallback? onDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Text(
            '$position',
            style: const TextStyle(
              color: RallyPairColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${names[group.firstPlayerId]} · ${names[group.secondPlayerId]}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: '上移',
            onPressed: busy ? null : onUp,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton(
            tooltip: '下移',
            onPressed: busy ? null : onDown,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
    );
  }
}
