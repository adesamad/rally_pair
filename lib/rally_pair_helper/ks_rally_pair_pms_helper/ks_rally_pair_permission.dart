import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rally_pair/rally_pair_helper/sw_rally_pair_dialog/sw_rally_pair_dialog.dart';
import 'ks_rally_pair_device_info.dart';
import 'ks_rally_pair_permission_text.dart';

class KsRallyPairPermission {
  const KsRallyPairPermission._();

  static const androidTypedMediaSdk = 33;
  static const androidScopedStorageSdk = 29;

  static Future<bool> isGranted(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() => _requestOne(
    permission: Permission.microphone,
    title: KsRallyPairPermissionText.microphoneTitle,
    purpose: KsRallyPairPermissionText.microphonePurpose,
    denied: KsRallyPairPermissionText.microphoneDenied,
  );

  static Future<bool> requestCamera() => _requestOne(
    permission: Permission.camera,
    title: KsRallyPairPermissionText.cameraTitle,
    purpose: KsRallyPairPermissionText.cameraPurpose,
    denied: KsRallyPairPermissionText.cameraDenied,
  );

  static Future<bool> requestPhotos({int? androidSdkInt}) async {
    if (Platform.isIOS) {
      return _requestOne(
        permission: Permission.photos,
        title: KsRallyPairPermissionText.photoTitle,
        purpose: KsRallyPairPermissionText.photoPurpose,
        denied: KsRallyPairPermissionText.photoDenied,
        limitedAsGranted: true,
      );
    }
    if (!Platform.isAndroid) return true;
    final sdk = androidSdkInt ?? await _androidSdkIntOr(androidTypedMediaSdk);
    return _requestOne(
      permission: sdk < androidTypedMediaSdk
          ? Permission.storage
          : Permission.photos,
      title: KsRallyPairPermissionText.photoTitle,
      purpose: KsRallyPairPermissionText.photoPurpose,
      denied: KsRallyPairPermissionText.photoDenied,
    );
  }

  static Future<bool> requestVideos({int? androidSdkInt}) async {
    if (Platform.isIOS) {
      return _requestOne(
        permission: Permission.photos,
        title: KsRallyPairPermissionText.videoTitle,
        purpose: KsRallyPairPermissionText.videoPurpose,
        denied: KsRallyPairPermissionText.videoDenied,
        limitedAsGranted: true,
      );
    }
    if (!Platform.isAndroid) return true;
    final sdk = androidSdkInt ?? await _androidSdkIntOr(androidTypedMediaSdk);
    return _requestOne(
      permission: sdk < androidTypedMediaSdk
          ? Permission.storage
          : Permission.videos,
      title: KsRallyPairPermissionText.videoTitle,
      purpose: KsRallyPairPermissionText.videoPurpose,
      denied: KsRallyPairPermissionText.videoDenied,
    );
  }

  static Future<bool> requestMedia({int? androidSdkInt}) async {
    if (Platform.isIOS) {
      return _requestOne(
        permission: Permission.photos,
        title: KsRallyPairPermissionText.mediaTitle,
        purpose: KsRallyPairPermissionText.mediaPurpose,
        denied: KsRallyPairPermissionText.mediaDenied,
        limitedAsGranted: true,
      );
    }
    if (!Platform.isAndroid) return true;
    final sdk = androidSdkInt ?? await _androidSdkIntOr(androidTypedMediaSdk);
    final permissions = sdk < androidTypedMediaSdk
        ? <Permission>[Permission.storage]
        : <Permission>[Permission.photos, Permission.videos];
    return _requestAll(
      permissions: permissions,
      title: KsRallyPairPermissionText.mediaTitle,
      purpose: KsRallyPairPermissionText.mediaPurpose,
      denied: KsRallyPairPermissionText.mediaDenied,
    );
  }

  static Future<bool> requestFiles({int? androidSdkInt}) async {
    if (!Platform.isAndroid) return true;
    final sdk =
        androidSdkInt ?? await _androidSdkIntOr(androidScopedStorageSdk);
    if (sdk >= androidScopedStorageSdk) return true;
    return _requestOne(
      permission: Permission.storage,
      title: KsRallyPairPermissionText.fileTitle,
      purpose: KsRallyPairPermissionText.filePurpose,
      denied: KsRallyPairPermissionText.fileDenied,
    );
  }

  static Future<int> _androidSdkIntOr(int fallback) async {
    await KsRallyPairDeviceInfo().init();
    final sdk = KsRallyPairDeviceInfo().androidSdkInt;
    if (sdk != null) return sdk;
    final match = RegExp(
      r'(?:SDK|API)\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(Platform.operatingSystemVersion);
    return int.tryParse(match?.group(1) ?? '') ?? fallback;
  }

  static Future<bool> _requestOne({
    required Permission permission,
    required String title,
    required String purpose,
    required String denied,
    bool limitedAsGranted = false,
  }) async {
    final current = await permission.status;
    if (_granted(current, limitedAsGranted)) return true;
    final proceed = await SwRallyPairDialog.confirm(
      title: title,
      content: purpose,
      confirmText: '继续',
      showCancel: false,
      clickMaskDismiss: false,
      backDismiss: false,
    );
    if (proceed != true) return false;
    final status = await permission.request();
    if (_granted(status, limitedAsGranted)) return true;
    if (status.isPermanentlyDenied) await _showSettings(title, denied);
    debugPrint('Rally Pair permission denied: $permission, status: $status');
    return false;
  }

  static Future<bool> _requestAll({
    required List<Permission> permissions,
    required String title,
    required String purpose,
    required String denied,
  }) async {
    final current = <PermissionStatus>[];
    for (final permission in permissions) {
      current.add(await permission.status);
    }
    if (current.every((status) => status.isGranted)) return true;
    final proceed = await SwRallyPairDialog.confirm(
      title: title,
      content: purpose,
      confirmText: '继续',
      showCancel: false,
      clickMaskDismiss: false,
      backDismiss: false,
    );
    if (proceed != true) return false;
    final statuses = await permissions.request();
    if (statuses.values.every((status) => status.isGranted)) return true;
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await _showSettings(title, denied);
    }
    debugPrint('Rally Pair permissions denied: $statuses');
    return false;
  }

  static bool _granted(PermissionStatus status, bool limitedAsGranted) {
    return status.isGranted || (limitedAsGranted && status.isLimited);
  }

  static Future<void> _showSettings(String title, String content) async {
    final open = await SwRallyPairDialog.confirm(
      title: title,
      content: content,
      confirmText: '去设置',
    );
    if (open == true) await openAppSettings();
  }
}
