part of 'live_session_page.dart';

class _CourtPane extends StatelessWidget {
  const _CourtPane({
    required this.session,
    required this.busy,
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
    required this.onRotate,
    required this.onFill,
    required this.onRelease,
    required this.onRemoveCourt,
  });

  final PlaySession session;
  final bool busy;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;
  final ValueChanged<SessionMatch> onRotate;
  final ValueChanged<int> onFill;
  final ValueChanged<int> onRelease;
  final ValueChanged<int> onRemoveCourt;

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
            canFill: session.waitingGroups.isNotEmpty,
            onStart: onStart,
            onCancel: onCancel,
            onRecordWinner: onRecordWinner,
            onRotate: onRotate,
            onFill: onFill,
            onRelease: onRelease,
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
    required this.onStart,
    required this.onCancel,
    required this.onRecordWinner,
    required this.onRotate,
    required this.onFill,
    required this.onRelease,
    required this.onRemoveCourt,
  });

  final Court court;
  final SessionMatch? match;
  final Map<int, String> names;
  final bool busy;
  final bool canFill;
  final Future<bool> Function(int matchId) onStart;
  final Future<bool> Function(int matchId) onCancel;
  final ValueChanged<SessionMatch> onRecordWinner;
  final ValueChanged<SessionMatch> onRotate;
  final ValueChanged<int> onFill;
  final ValueChanged<int> onRelease;
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
            const Text(
              '场地空闲，可按候场顺序安排两组。',
              style: TextStyle(color: RallyPairColors.textSecondary),
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
                      child: const Text('补入下一组'),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: busy ? null : () => onRemoveCourt(court.number),
                  child: const Text('移除空闲场地'),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 18),
            _BadmintonCourt(match: current, names: names),
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
                        RallyPairIcon(
                          current.state == MatchState.ready
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

class _BadmintonCourt extends StatelessWidget {
  const _BadmintonCourt({this.match, this.names = const {}});

  final SessionMatch? match;
  final Map<int, String> names;

  @override
  Widget build(BuildContext context) {
    final match = this.match;
    return Semantics(
      container: true,
      label: match == null ? '空闲羽毛球场' : '羽毛球场，两组四名玩家',
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
                  alignment: const Alignment(-0.56, -0.54),
                  name: names[match.teamA.first] ?? '未知玩家',
                ),
                _CourtPlayer(
                  alignment: const Alignment(0.56, -0.54),
                  name: names[match.teamA.second] ?? '未知玩家',
                ),
                _CourtPlayer(
                  alignment: const Alignment(-0.56, 0.54),
                  name: names[match.teamB.first] ?? '未知玩家',
                ),
                _CourtPlayer(
                  alignment: const Alignment(0.56, 0.54),
                  name: names[match.teamB.second] ?? '未知玩家',
                ),
                if (match.result != null)
                  Align(
                    alignment: Alignment.center,
                    child: _CourtPlayerLabel(
                      label: match.result!.games.isEmpty
                          ? match.result!.winner == Side.a
                                ? '上方胜 · 待轮转'
                                : '下方胜 · 待轮转'
                          : match.result!.games
                                .map((game) => '${game.a}:${game.b}')
                                .join('  '),
                    ),
                  ),
              ],
            ],
          ),
        ),
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
