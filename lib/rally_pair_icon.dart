import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum RallyPairIconData {
  session('session'),
  history('history'),
  court('court'),
  grouping('grouping'),
  waitingQueue('waiting-queue'),
  rotation('rotation'),
  result('result'),
  playerAdd('player-add'),
  playerRest('player-rest'),
  playerLeave('player-leave'),
  matchStart('match-start'),
  scoreEntry('score-entry');

  const RallyPairIconData(this.assetName);

  final String assetName;
}

class RallyPairIcon extends StatelessWidget {
  const RallyPairIcon(
    this.data, {
    super.key,
    this.size = 24,
    required this.semanticLabel,
  });

  final RallyPairIconData data;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/${data.assetName}.svg',
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
    );
  }
}
