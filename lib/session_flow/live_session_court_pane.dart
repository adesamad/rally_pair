part of 'live_session_page.dart';

class _CourtPane extends StatelessWidget {
  const _CourtPane({
    required this.session,
    required this.busy,
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
  });

  final PlaySession session;
  final bool busy;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;

  @override
  Widget build(BuildContext context) {
    final matches = {for (final match in session.matches) match.id: match};
    final names = _playerNames(session);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(title: '现场球场', description: '从这里开赛、取消比赛或登记胜方。'),
        const SizedBox(height: 18),
        for (var index = 0; index < session.courts.length; index++) ...[
          _CourtCard(
            court: session.courts[index],
            match: session.courts[index].matchId == null
                ? null
                : matches[session.courts[index].matchId],
            names: names,
            busy: busy,
            onStart: onStart,
            onCancel: onCancel,
            onRecordWinner: onRecordWinner,
          ),
          if (index != session.courts.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CourtCard extends StatelessWidget {
  const _CourtCard({
    required this.court,
    required this.match,
    required this.names,
    required this.busy,
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
  });

  final Court court;
  final SessionMatch? match;
  final Map<int, String> names;
  final bool busy;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;

  @override
  Widget build(BuildContext context) {
    final current = match;
    final inPlay = current?.state == MatchState.inProgress;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: inPlay ? const Color(0xFFE5F5EE) : RallyPairColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: inPlay ? RallyPairColors.court : RallyPairColors.outline,
          width: inPlay ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: RallyPairColors.court,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  '${court.number}',
                  style: const TextStyle(
                    color: RallyPairColors.courtLine,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${court.number} 号场',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _CourtStatus(state: court.state),
            ],
          ),
          if (current == null) ...[
            const SizedBox(height: 18),
            const Text(
              '场地空闲，前往“分组”安排下一场。',
              style: TextStyle(color: RallyPairColors.textSecondary),
            ),
          ] else ...[
            const SizedBox(height: 18),
            _MatchTeams(match: current, names: names),
            if (current.relaxed) ...[
              const SizedBox(height: 10),
              const Text(
                '本组已放宽连续搭档限制。',
                style: TextStyle(
                  color: RallyPairColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    key: ValueKey(
                      current.state == MatchState.ready
                          ? 'start-match-${current.id}'
                          : 'record-result-${current.id}',
                    ),
                    onPressed: busy
                        ? null
                        : current.state == MatchState.ready
                        ? () => onStart(current.id)
                        : () => onRecordWinner(current),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RallyPairIcon(
                          current.state == MatchState.ready
                              ? RallyPairIconData.matchStart
                              : RallyPairIconData.scoreEntry,
                          semanticLabel: current.state == MatchState.ready
                              ? '开始比赛'
                              : '录入胜方',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          current.state == MatchState.ready ? '开始比赛' : '录入胜方',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: busy ? null : () => onCancel(current.id),
                  child: const Text('取消比赛'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CourtStatus extends StatelessWidget {
  const _CourtStatus({required this.state});

  final CourtState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      CourtState.available => ('空闲', RallyPairColors.textSecondary),
      CourtState.reserved => ('待开赛', RallyPairColors.primary),
      CourtState.inPlay => ('比赛中', RallyPairColors.court),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MatchTeams extends StatelessWidget {
  const _MatchTeams({required this.match, required this.names});

  final SessionMatch match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _TeamBlock(label: 'A 组', names: _teamName(match.teamA, names)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'VS',
            style: TextStyle(
              color: RallyPairColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: _TeamBlock(label: 'B 组', names: _teamName(match.teamB, names)),
        ),
      ],
    );
  }
}

class _TeamBlock extends StatelessWidget {
  const _TeamBlock({required this.label, required this.names});

  final String label;
  final String names;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: RallyPairColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(names, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
