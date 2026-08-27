part of 'live_session_page.dart';

class _GroupingPane extends StatelessWidget {
  const _GroupingPane({
    required this.session,
    required this.busy,
    required this.onGenerate,
    required this.onRegenerate,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onGenerate;
  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    final ready = session.matches
        .where((match) => match.state == MatchState.ready)
        .toList(growable: false);
    final names = _playerNames(session);
    final availableCourts = session.courts
        .where((court) => court.state == CourtState.available)
        .length;
    final canGenerate =
        session.waitingPlayers.length >= 4 && availableCourts > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(
          title: '安排下一轮',
          description: '系统会根据场地、候场顺序和搭档记录生成双打分组。',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ready.isEmpty ? '尚未安排待开赛分组' : '已安排 ${ready.length} 场',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '$availableCourts 块空闲场地 · ${session.waitingPlayers.length} 名候场玩家',
                style: const TextStyle(color: RallyPairColors.textSecondary),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('generate-assignments'),
                onPressed: busy
                    ? null
                    : ready.isNotEmpty
                    ? onRegenerate
                    : canGenerate
                    ? onGenerate
                    : null,
                child: Text(ready.isNotEmpty ? '重新分组' : '生成分组'),
              ),
              if (ready.isEmpty && !canGenerate) ...[
                const SizedBox(height: 10),
                const Text(
                  '需要至少 4 名候场玩家和 1 块空闲场地。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: RallyPairColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (ready.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('待开赛分组', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          for (var index = 0; index < ready.length; index++) ...[
            _ReadyMatchCard(match: ready[index], names: names),
            if (index != ready.length - 1) const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _ReadyMatchCard extends StatelessWidget {
  const _ReadyMatchCard({required this.match, required this.names});

  final SessionMatch match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${match.courtNumber} 号场',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          _MatchTeams(match: match, names: names),
          if (match.relaxed) ...[
            const SizedBox(height: 10),
            const Text(
              '已放宽连续搭档限制',
              style: TextStyle(
                color: RallyPairColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
