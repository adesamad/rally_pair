part of 'live_session_page.dart';

class _RotationPane extends StatelessWidget {
  const _RotationPane({required this.session});

  final PlaySession session;

  @override
  Widget build(BuildContext context) {
    final policy = session.setup.pairingPolicy == PairingPolicy.fairRotation
        ? '公平轮转'
        : '完全随机';
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(
          title: '轮转依据',
          description: '这里展示下一轮分组会使用的候场顺序和已完成场次。',
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: RallyPairColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: RallyPairColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RuleLine(label: '分组方式', value: policy),
              const SizedBox(height: 12),
              _RuleLine(
                label: '连续搭档',
                value: session.setup.avoidRecentPartner ? '尽量避免' : '不限制',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('当前候场顺序', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (session.waitingPlayers.isEmpty)
          const _SimpleEmpty(message: '现在没有候场玩家。')
        else
          for (
            var index = 0;
            index < session.waitingPlayers.length;
            index++
          ) ...[
            _QueueRow(
              position: index + 1,
              player: session.waitingPlayers[index],
              completedMatches: session
                  .statsFor(session.waitingPlayers[index].id)
                  .completedMatches,
            ),
            if (index != session.waitingPlayers.length - 1)
              const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: RallyPairColors.textSecondary),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    required this.position,
    required this.player,
    required this.completedMatches,
  });

  final int position;
  final SessionPlayer player;
  final int completedMatches;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            '已打 $completedMatches 场',
            style: const TextStyle(color: RallyPairColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
