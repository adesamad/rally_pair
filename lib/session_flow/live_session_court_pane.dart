part of 'live_session_page.dart';

class _CourtPane extends StatelessWidget {
  const _CourtPane({
    required this.session,
    required this.busy,
    required this.onGenerate,
    required this.onRegenerate,
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
    required this.onRotate,
    required this.onFill,
    required this.onRelease,
    required this.onAssignNext,
    required this.onAssignSpecific,
    required this.onRemoveCourt,
  });

  final PlaySession session;
  final bool busy;
  final VoidCallback onGenerate;
  final VoidCallback onRegenerate;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;
  final ValueChanged<SessionMatch> onRotate;
  final ValueChanged<int> onFill;
  final ValueChanged<int> onRelease;
  final ValueChanged<int> onAssignNext;
  final ValueChanged<int> onAssignSpecific;
  final ValueChanged<int> onRemoveCourt;

  @override
  Widget build(BuildContext context) {
    final matches = {for (final match in session.matches) match.id: match};
    final names = _playerNames(session);
    final readyCount = session.matches
        .where((match) => match.state == MatchState.ready)
        .length;
    final availableCount = session.courts
        .where((court) => court.state == CourtState.available)
        .length;
    final singles = session.setup.matchFormat == MatchFormat.singles;
    final waitingCount = singles
        ? session.waitingPlayers.length
        : session.waitingGroups.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const _SectionIntro(title: '现场球场', description: '从这里开赛、取消比赛或登记胜方。'),
        if (readyCount > 0 || (availableCount > 0 && waitingCount >= 2)) ...[
          const SizedBox(height: 12),
          OutlinedButton(
            key: const ValueKey('generate-assignments'),
            onPressed: busy
                ? null
                : readyCount > 0
                ? onRegenerate
                : onGenerate,
            child: Text(readyCount > 0 ? '重新安排待开赛场次' : '为空闲场地批量安排'),
          ),
        ],
        const SizedBox(height: 18),
        for (var index = 0; index < session.courts.length; index++) ...[
          _CourtCard(
            court: session.courts[index],
            match: session.courts[index].matchId == null
                ? null
                : matches[session.courts[index].matchId],
            names: names,
            busy: busy,
            canFill: waitingCount > 0,
            canAssign: waitingCount >= 2,
            singles: singles,
            onStart: onStart,
            onCancel: onCancel,
            onRecordWinner: onRecordWinner,
            onRotate: onRotate,
            onFill: onFill,
            onRelease: onRelease,
            onAssignNext: onAssignNext,
            onAssignSpecific: onAssignSpecific,
            onRemoveCourt: onRemoveCourt,
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
    required this.canFill,
    required this.canAssign,
    required this.singles,
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
    required this.onRotate,
    required this.onFill,
    required this.onRelease,
    required this.onAssignNext,
    required this.onAssignSpecific,
    required this.onRemoveCourt,
  });

  final Court court;
  final SessionMatch? match;
  final Map<int, String> names;
  final bool busy;
  final bool canFill;
  final bool canAssign;
  final bool singles;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;
  final ValueChanged<SessionMatch> onRotate;
  final ValueChanged<int> onFill;
  final ValueChanged<int> onRelease;
  final ValueChanged<int> onAssignNext;
  final ValueChanged<int> onAssignSpecific;
  final ValueChanged<int> onRemoveCourt;

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
            const _BadmintonCourt(),
            const SizedBox(height: 12),
            Text(
              singles ? '场地空闲，可按候场顺序安排两名球友。' : '场地空闲，可按候场顺序安排两组。',
              style: const TextStyle(color: RallyPairColors.textSecondary),
            ),
            if (court.state == CourtState.waitingOpponent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: busy || !canFill
                          ? null
                          : () => onFill(court.number),
                      child: Text(singles ? '补入下一人' : '补入下一组'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: busy ? null : () => onRelease(court.number),
                    child: const Text('结束留场'),
                  ),
                ],
              ),
            ] else if (court.state == CourtState.available) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('assign-next-${court.number}'),
                      onPressed: busy || !canAssign
                          ? null
                          : () => onAssignNext(court.number),
                      child: const Text('按顺序安排'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    key: ValueKey('assign-specific-${court.number}'),
                    onPressed: busy || !canAssign
                        ? null
                        : () => onAssignSpecific(court.number),
                    child: const Text('手动安排'),
                  ),
                ],
              ),
            ],
          ] else ...[
            const SizedBox(height: 18),
            _BadmintonCourt(match: current, names: names),
            if (current.result != null) ...[
              const SizedBox(height: 10),
              _MatchResultSummary(match: current),
            ],
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
                        : current.state == MatchState.resultRecorded
                        ? () => onRotate(current)
                        : () => onRecordWinner(current),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CourtActionIcon(
                          data: current.state == MatchState.ready
                              ? RallyPairIconData.matchStart
                              : current.state == MatchState.resultRecorded
                              ? RallyPairIconData.rotation
                              : RallyPairIconData.scoreEntry,
                          semanticLabel: current.state == MatchState.ready
                              ? '开始比赛'
                              : current.state == MatchState.resultRecorded
                              ? '决定上下场'
                              : '录入胜方',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          current.state == MatchState.ready
                              ? '开始比赛'
                              : current.state == MatchState.resultRecorded
                              ? '决定上下场'
                              : '录入胜方',
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

class _CourtActionIcon extends StatelessWidget {
  const _CourtActionIcon({required this.data, required this.semanticLabel});

  final RallyPairIconData data;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RallyPairColors.surface,
        borderRadius: BorderRadius.circular(9),
      ),
      child: RallyPairIcon(data, semanticLabel: semanticLabel, size: 18),
    );
  }
}

class _BadmintonCourt extends StatelessWidget {
  const _BadmintonCourt({this.match, this.names = const {}});

  final SessionMatch? match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final match = this.match;
    return Semantics(
      container: true,
      label: match == null ? '空闲羽毛球场' : '羽毛球场，${match.players.length} 名玩家',
      child: AspectRatio(
        key: ValueKey('court-surface-${match?.id ?? 'empty'}'),
        aspectRatio: 1.48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: RallyPairColors.court),
              const CustomPaint(painter: _CourtLinesPainter()),
              if (match == null)
                const Center(
                  child: _CourtPlayerLabel(label: '等待分配', muted: true),
                )
              else ...[
                _CourtPlayer(
                  alignment: Alignment(
                    match.teamA.second == null ? 0 : -0.56,
                    -0.54,
                  ),
                  name: names[match.teamA.first] ?? '未知玩家',
                ),
                if (match.teamA.second case final second?)
                  _CourtPlayer(
                    alignment: const Alignment(0.56, -0.54),
                    name: names[second] ?? '未知玩家',
                  ),
                _CourtPlayer(
                  alignment: Alignment(
                    match.teamB.second == null ? 0 : -0.56,
                    0.54,
                  ),
                  name: names[match.teamB.first] ?? '未知玩家',
                ),
                if (match.teamB.second case final second?)
                  _CourtPlayer(
                    alignment: const Alignment(0.56, 0.54),
                    name: names[second] ?? '未知玩家',
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchResultSummary extends StatelessWidget {
  const _MatchResultSummary({required this.match});

  final SessionMatch match;

  @override
  Widget build(BuildContext context) {
    final result = match.result!;
    final hasScores = result.games.isNotEmpty;
    final value = hasScores
        ? result.games.map((game) => '${game.a}:${game.b}').join('  ')
        : result.winner == Side.a
        ? '上方组合获胜'
        : '下方组合获胜';
    return Container(
      key: ValueKey('match-result-summary-${match.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: RallyPairColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RallyPairColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasScores ? '已录入比分' : '已录入胜方',
                  style: const TextStyle(
                    color: RallyPairColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '待决定上下场',
            style: TextStyle(
              color: RallyPairColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtPlayer extends StatelessWidget {
  const _CourtPlayer({required this.alignment, required this.name});

  final Alignment alignment;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: .26,
        heightFactor: .2,
        child: _CourtPlayerLabel(label: name),
      ),
    );
  }
}

class _CourtPlayerLabel extends StatelessWidget {
  const _CourtPlayerLabel({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 36),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: muted
            ? RallyPairColors.courtLine.withAlpha(38)
            : RallyPairColors.surface.withAlpha(235),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RallyPairColors.courtLine, width: 1.4),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: muted
              ? RallyPairColors.courtLine
              : RallyPairColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CourtLinesPainter extends CustomPainter {
  const _CourtLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = RallyPairColors.courtLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final court = Rect.fromLTWH(12, 12, size.width - 24, size.height - 24);
    canvas.drawRect(court, paint);
    canvas.drawLine(
      Offset(court.left, court.center.dy),
      Offset(court.right, court.center.dy),
      paint..strokeWidth = 3,
    );
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(court.center.dx, court.top),
      Offset(court.center.dx, court.bottom),
      paint,
    );
    final serviceInset = court.height * .22;
    canvas.drawLine(
      Offset(court.left, court.top + serviceInset),
      Offset(court.right, court.top + serviceInset),
      paint,
    );
    canvas.drawLine(
      Offset(court.left, court.bottom - serviceInset),
      Offset(court.right, court.bottom - serviceInset),
      paint,
    );
    final sideInset = court.width * .08;
    canvas.drawLine(
      Offset(court.left + sideInset, court.top),
      Offset(court.left + sideInset, court.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(court.right - sideInset, court.top),
      Offset(court.right - sideInset, court.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CourtLinesPainter oldDelegate) => false;
}

class _CourtStatus extends StatelessWidget {
  const _CourtStatus({required this.state});

  final CourtState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      CourtState.available => ('空闲', RallyPairColors.textSecondary),
      CourtState.ready ||
      CourtState.reserved => ('待开赛', RallyPairColors.primary),
      CourtState.inPlay => ('比赛中', RallyPairColors.court),
      CourtState.awaitingRotation => ('待轮转', RallyPairColors.primary),
      CourtState.waitingOpponent => ('待补位', RallyPairColors.court),
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
