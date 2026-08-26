import 'package:flutter/widgets.dart';

enum RallyPairIconAsset {
  session('session', '球局'),
  playerAdd('player-add', '添加玩家');

  const RallyPairIconAsset(this.fileName, this.semanticLabel);

  final String fileName;
  final String semanticLabel;
}

class RallyPairIcon extends StatelessWidget {
  const RallyPairIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.semanticLabel,
  });

  final RallyPairIconAsset asset;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/${asset.fileName}.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel ?? asset.semanticLabel,
    );
  }
}
