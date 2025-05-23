import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/windows_web_view_service.dart';

abstract class WindowsBarcodeScanner {
  static const String _channelName = 'QR Scanned';

  static Future<void> scan(void Function(String) onScanned) async {
    await WindowsWebViewService.initialize();

    final isWebViewAvailable = await WindowsWebViewService.isWebViewAvailable();
    if (!isWebViewAvailable) {
      Logger().d('WebView is not available.');

      WindowsWebViewService.close();
    }

    final isPermissionGranted = await _checkCameraPermission();
    if (!isPermissionGranted) {
      Logger().d('Camera permission is not granted.');

      WindowsWebViewService.close();
    }

    WindowsWebViewService.registerJavascriptMessageHandler(
        channelName: _channelName,
        onMessage: (name, body) {
          final data = 'name: $name, body: $body';
          onScanned(data);

          // if (name == "successCallback") {
          //   if (body is String &&
          //       body.isNotEmpty) {
          //
          //     onScanned(body);
          //
          //     WindowsWebViewService.unregisterJavascriptMessageHandler(
          //         channelName: _channelName);
          //
          //     WindowsWebViewService.close();
          //   }
          // }
        });

    final url = getAssetFileUrl(asset: PackageConstant.barcodeFilePath);
    WindowsWebViewService.launch(url);
  }

  static Future<bool> _checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  static String getAssetFileUrl({required String asset}) {
    final assetsDirectory = p.join(p.dirname(Platform.resolvedExecutable),
        'data', 'flutter_assets', asset);
    return Uri.file(assetsDirectory).toString();
  }
}
