part of 'live_session_page.dart';

class _GroupingPane extends StatelessWidget {
  const _GroupingPane({
    required this.session,
    required this.busy,
    required this.onGenerate,
    required this.onRegenerate,
    required this.onRandomGroups,
    required this.onManualGroup,
    required this.onReplaceGroupPlayer,
    required this.onDissolveGroup,
    required this.onAssignSpecific,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onGenerate;
  final VoidCallback onRegenerate;
  final VoidCallback onRandomGroups;
  final VoidCallback onManualGroup;
  final ValueChanged<PairingGroup> onReplaceGroupPlayer;
  final ValueChanged<PairingGroup> onDissolveGroup;
  final VoidCallback onAssignSpecific;

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
        session.waitingGroups.length >= 2 && availableCourts > 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(
          title: '组队与上场',
          description: '先形成固定双人组，再按随机或手动顺序安排到具体场地。',
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
              Text('固定双人组', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                '${session.players.where((player) => player.state == PlayerState.ungrouped).length} 人未成组 · ${session.waitingGroups.length} 组候场',
                style: const TextStyle(color: RallyPairColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed:
                          busy ||
                              session.players
                                      .where(
                                        (player) =>
                                            player.state ==
                                            PlayerState.ungrouped,
                                      )
                                      .length <
                                  2
                          ? null
                          : onRandomGroups,
                      child: const Text('随机组队'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          busy ||
                              session.players
                                      .where(
                                        (player) =>
                                            player.state ==
                                            PlayerState.ungrouped,
                                      )
                                      .length <
                                  2
                          ? null
                          : onManualGroup,
                      child: const Text('手动组队'),
                    ),
                  ),
                ],
              ),
              if (session.waitingGroups.isNotEmpty) ...[
                const SizedBox(height: 14),
                for (final group in session.waitingGroups)
                  _WaitingGroupCard(
                    group: group,
                    names: names,
                    busy: busy,
                    canReplace: session.players.any(
                      (player) => player.state == PlayerState.ungrouped,
                    ),
                    onReplace: () => onReplaceGroupPlayer(group),
                    onDissolve: () => onDissolveGroup(group),
                  ),
              ],
            ],
          ),
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
                '$availableCourts 块空闲场地 · ${session.waitingGroups.length} 个候场组',
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
              const SizedBox(height: 10),
              OutlinedButton(
                key: const ValueKey('assign-specific-groups'),
                onPressed: busy || !canGenerate ? null : onAssignSpecific,
                child: const Text('手动选择场地与两组'),
              ),
              if (ready.isEmpty && !canGenerate) ...[
                const SizedBox(height: 10),
                const Text(
                  '需要至少 2 个候场组和 1 块空闲场地。',
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

class _WaitingGroupCard extends StatelessWidget {
  const _WaitingGroupCard({
    required this.group,
    required this.names,
    required this.busy,
    required this.canReplace,
    required this.onReplace,
    required this.onDissolve,
  });

  final PairingGroup group;
  final Map<int, String> names;
  final bool busy;
  final bool canReplace;
  final VoidCallback onReplace;
  final VoidCallback onDissolve;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${names[group.firstPlayerId]} · ${names[group.secondPlayerId]}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: busy || !canReplace ? null : onReplace,
            child: const Text('换人'),
          ),
          TextButton(
            onPressed: busy ? null : onDissolve,
            child: const Text('解散'),
          ),
        ],
      ),
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
