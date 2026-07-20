import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DownloadService {
  static const MethodChannel _channel = MethodChannel('com.wallvault/wallpaper');

  /// S46 — Check platform storage permission.
  Future<bool> checkStoragePermission() async {
    // In production, we'd call permission_handler.
    // Return true for mock check.
    return true;
  }

  /// S46 — Apply wallpaper via platform channels using WallpaperManager.
  /// Target: 1 (Home Screen), 2 (Lock Screen), 3 (Both)
  Future<bool> applyDeviceWallpaper(String filePath, int target) async {
    try {
      final bool result = await _channel.invokeMethod('applyWallpaper', {
        'path': filePath,
        'target': target,
      });
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check connectivity status for downloads.
  Future<bool> isNetworkAvailable() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}
