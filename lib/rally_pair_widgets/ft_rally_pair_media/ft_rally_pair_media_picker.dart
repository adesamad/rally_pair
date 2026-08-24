import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rally_pair/rally_pair_helper/ks_rally_pair_pms_helper/ks_rally_pair_pms_helper.dart';
import 'package:rally_pair/rally_pair_helper/sw_rally_pair_dialog/sw_rally_pair_dialog.dart';

enum FtRallyPairMediaType { image, video, file }

enum FtRallyPairMediaSource { camera, gallery, recorder, file }

class FtRallyPairPickedMedia {
  const FtRallyPairPickedMedia({
    required this.path,
    required this.type,
    required this.source,
    this.name,
    this.size,
    this.extension,
  });

  final String path;
  final FtRallyPairMediaType type;
  final FtRallyPairMediaSource source;
  final String? name;
  final int? size;
  final String? extension;

  bool get isImage => type == FtRallyPairMediaType.image;
  bool get isVideo => type == FtRallyPairMediaType.video;
  bool get isFile => type == FtRallyPairMediaType.file;
}

class FtRallyPairMediaPicker {
  FtRallyPairMediaPicker._();

  static final _picker = ImagePicker();

  static Future<FtRallyPairPickedMedia?> pickImage() async {
    final source = await SwRallyPairDialog.choose<FtRallyPairMediaSource>(
      tag: 'ftRallyPairImageSource',
      title: '选择图片',
      options: const <SwRallyPairDialogOption<FtRallyPairMediaSource>>[
        SwRallyPairDialogOption(
          label: '拍照',
          value: FtRallyPairMediaSource.camera,
        ),
        SwRallyPairDialogOption(
          label: '从相册选择',
          value: FtRallyPairMediaSource.gallery,
        ),
      ],
    );
    return switch (source) {
      FtRallyPairMediaSource.camera => _pickImage(ImageSource.camera),
      FtRallyPairMediaSource.gallery => _pickImage(ImageSource.gallery),
      _ => null,
    };
  }

  static Future<FtRallyPairPickedMedia?> pickVideo() async {
    final source = await SwRallyPairDialog.choose<FtRallyPairMediaSource>(
      tag: 'ftRallyPairVideoSource',
      title: '选择视频',
      options: const <SwRallyPairDialogOption<FtRallyPairMediaSource>>[
        SwRallyPairDialogOption(
          label: '录制视频',
          value: FtRallyPairMediaSource.recorder,
        ),
        SwRallyPairDialogOption(
          label: '从相册选择',
          value: FtRallyPairMediaSource.gallery,
        ),
      ],
    );
    return switch (source) {
      FtRallyPairMediaSource.recorder => _pickVideo(ImageSource.camera),
      FtRallyPairMediaSource.gallery => _pickVideo(ImageSource.gallery),
      _ => null,
    };
  }

  static Future<FtRallyPairPickedMedia?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    if (!await KsRallyPairPermission.requestFiles()) return null;
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    final file = result?.files.firstOrNull;
    final path = file?.path;
    if (file == null || path == null || path.trim().isEmpty) return null;
    return FtRallyPairPickedMedia(
      path: path,
      type: FtRallyPairMediaType.file,
      source: FtRallyPairMediaSource.file,
      name: file.name,
      size: file.size,
      extension: file.extension,
    );
  }

  static Future<FtRallyPairPickedMedia?> _pickImage(ImageSource source) async {
    final granted = source == ImageSource.camera
        ? await KsRallyPairPermission.requestCamera()
        : await KsRallyPairPermission.requestPhotos();
    if (!granted) return null;
    final file = await _picker.pickImage(source: source);
    return _fromXFile(
      file,
      type: FtRallyPairMediaType.image,
      source: source == ImageSource.camera
          ? FtRallyPairMediaSource.camera
          : FtRallyPairMediaSource.gallery,
    );
  }

  static Future<FtRallyPairPickedMedia?> _pickVideo(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (!await KsRallyPairPermission.requestCamera()) return null;
      if (!await KsRallyPairPermission.requestMicrophone()) return null;
    } else if (!await KsRallyPairPermission.requestVideos()) {
      return null;
    }
    final file = await _picker.pickVideo(source: source);
    return _fromXFile(
      file,
      type: FtRallyPairMediaType.video,
      source: source == ImageSource.camera
          ? FtRallyPairMediaSource.recorder
          : FtRallyPairMediaSource.gallery,
    );
  }

  static FtRallyPairPickedMedia? _fromXFile(
    XFile? file, {
    required FtRallyPairMediaType type,
    required FtRallyPairMediaSource source,
  }) {
    if (file == null || file.path.trim().isEmpty) return null;
    return FtRallyPairPickedMedia(
      path: file.path,
      type: type,
      source: source,
      name: file.name,
    );
  }
}
