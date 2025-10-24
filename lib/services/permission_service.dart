import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Richiedi permesso per la galleria
  static Future<bool> requestGalleryPermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.photos.request();
    }

    return status.isGranted;
  }

  /// Richiedi permesso per la camera
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Apri impostazioni app
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}