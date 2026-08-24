import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'ft_rally_pair_media_picker.dart';

class FtRallyPairMediaPreview extends StatelessWidget {
  const FtRallyPairMediaPreview({super.key, required this.media});

  final FtRallyPairPickedMedia media;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _open(context),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: switch (media.type) {
                    FtRallyPairMediaType.image => _ImageThumb(path: media.path),
                    FtRallyPairMediaType.video => _VideoThumb(path: media.path),
                    FtRallyPairMediaType.file => _FileThumb(media: media),
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(_title, style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                media.path,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title {
    final name = media.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    return switch (media.type) {
      FtRallyPairMediaType.image => '图片预览',
      FtRallyPairMediaType.video => '视频预览',
      FtRallyPairMediaType.file => '文件信息',
    };
  }

  void _open(BuildContext context) {
    final page = switch (media.type) {
      FtRallyPairMediaType.image => _ImagePage(media: media),
      FtRallyPairMediaType.video => _VideoPage(media: media),
      FtRallyPairMediaType.file => _FilePage(media: media),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const _PreviewError(text: '图片加载失败'),
    );
  }
}

class _VideoThumb extends StatefulWidget {
  const _VideoThumb({required this.path});

  final String path;

  @override
  State<_VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<_VideoThumb> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializing;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _initializing = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializing,
      builder: (_, snapshot) {
        if (snapshot.hasError) return const _PreviewError(text: '视频加载失败');
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 100 * _aspectRatio(_controller.value),
                height: 100,
                child: VideoPlayer(_controller),
              ),
            ),
            // TODO(icon-system): replace with the approved Rally Pair 24px icon family.
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FileThumb extends StatelessWidget {
  const _FileThumb({required this.media});

  final FtRallyPairPickedMedia media;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO(icon-system): replace with the approved Rally Pair 24px icon family.
            Icon(
              Icons.insert_drive_file_outlined,
              size: 40,
              color: colors.primary,
            ),
            const SizedBox(height: 8),
            Text(media.extension?.toUpperCase() ?? 'FILE'),
          ],
        ),
      ),
    );
  }
}

class _ImagePage extends StatelessWidget {
  const _ImagePage({required this.media});

  final FtRallyPairPickedMedia media;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(media.name ?? '图片查看'),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.file(
            File(media.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const _PreviewError(text: '图片加载失败', color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _VideoPage extends StatefulWidget {
  const _VideoPage({required this.media});

  final FtRallyPairPickedMedia media;

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  late final VideoPlayerController _video;
  late final Future<void> _initializing;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.file(File(widget.media.path));
    _initializing = _video.initialize().then((_) {
      if (!mounted) return;
      _chewie = ChewieController(
        videoPlayerController: _video,
        autoPlay: true,
        looping: false,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.media.name ?? '视频查看'),
      ),
      body: FutureBuilder<void>(
        future: _initializing,
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            return const _PreviewError(text: '视频加载失败', color: Colors.white);
          }
          final controller = _chewie;
          if (snapshot.connectionState != ConnectionState.done ||
              controller == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(child: Chewie(controller: controller));
        },
      ),
    );
  }
}

class _FilePage extends StatelessWidget {
  const _FilePage({required this.media});

  final FtRallyPairPickedMedia media;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(media.name ?? '文件信息')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          <String>[
            '类型：${media.type.name}',
            '来源：${media.source.name}',
            if (media.name != null) '名称：${media.name}',
            if (media.extension != null) '扩展名：${media.extension}',
            if (media.size != null) '大小：${media.size} B',
            '路径：${media.path}',
          ].join('\n'),
        ),
      ),
    );
  }
}

class _PreviewError extends StatelessWidget {
  const _PreviewError({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

double _aspectRatio(VideoPlayerValue value) {
  final ratio = value.aspectRatio;
  if (ratio <= 0) return 16 / 9;
  return value.rotationCorrection.abs() % 180 == 90 ? 1 / ratio : ratio;
}
