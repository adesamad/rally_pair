part of 'live_session_page.dart';

class _GroupingPane extends StatelessWidget {
  const _GroupingPane({
    required this.session,
    required this.busy,
    required this.onRandomGroups,
    required this.onManualGroup,
    required this.onReplaceGroupPlayer,
    required this.onDissolveGroup,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onRandomGroups;
  final VoidCallback onManualGroup;
  final ValueChanged<PairingGroup> onReplaceGroupPlayer;
  final ValueChanged<PairingGroup> onDissolveGroup;

  @override
  Widget build(BuildContext context) {
    final names = _playerNames(session);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(
          title: '固定双人组',
          description: '把未成组球友组成固定搭档，完成后会进入候场顺序。',
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
