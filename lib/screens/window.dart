import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/windows_web_view_service.dart';

import '../barcode_appbar.dart';

class WindowBarcodeScanner extends StatefulWidget {
  final String lineColor;
  final String cancelButtonText;
  final bool isShowFlashIcon;
  final ScanType scanType;
  final CameraFace cameraFace;
  final Function(String) onScanned;
  final String? appBarTitle;
  final bool? centerTitle;
  final BarcodeAppBar? barcodeAppBar;
  final int? delayMillis;
  final Function? onClose;

  const WindowBarcodeScanner({
    super.key,
    required this.lineColor,
    required this.cancelButtonText,
    required this.isShowFlashIcon,
    required this.scanType,
    this.cameraFace = CameraFace.back,
    required this.onScanned,
    this.appBarTitle,
    this.centerTitle,
    this.barcodeAppBar,
    this.delayMillis,
    this.onClose,
  });

  @override
  State<WindowBarcodeScanner> createState() => _WindowBarcodeScannerState();
}

class _WindowBarcodeScannerState extends State<WindowBarcodeScanner> {
  static const String _channelName = 'QR Scanned';

  @override
  void initState() {
    super.initState();

    initializeWebView();
  }

  @override
  void dispose() {
    super.dispose();

    WindowsWebViewService.unregisterJavascriptMessageHandler(
      channelName: _channelName,
    );
  }

  void initializeWebView() async {
    await WindowsWebViewService.initialize();

    final isWebViewAvailable = await WindowsWebViewService.isWebViewAvailable();
    if (!isWebViewAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('WebView is not available.'),
        ),
      );

      Navigator.pop(context);
    }

    final isPermissionGranted = await _checkCameraPermission();
    if (!isPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera permission is not granted.'),
        ),
      );

      Navigator.pop(context);
    }

    WindowsWebViewService.registerJavascriptMessageHandler(channelName: _channelName, onMessage: (name, body) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name: $name, Body: $body'),
        ),
      );
    });

    final url = getAssetFileUrl(asset: PackageConstant.barcodeFilePath);
    WindowsWebViewService.launch(url);
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox();
  }

  Future<bool> _checkCameraPermission() async {
    return await Permission.camera.request().isGranted;
  }

  String getAssetFileUrl({required String asset}) {
    final assetsDirectory = p.join(p.dirname(Platform.resolvedExecutable),
        'data', 'flutter_assets', asset);
    return Uri.file(assetsDirectory).toString();
  }

  // Future<void> initPlatformState(
  //     {required WebviewController controller}) async {
  //   String? barcodeNumber;
  //
  //   try {
  //     await controller.initialize();
  //     await controller
  //         .loadUrl();
  //
  //     /// Listen to web to receive barcode
  //     controller.webMessage.listen((event) {
  //       if (event['methodName'] == "successCallback") {
  //         if (event['data'] is String &&
  //             event['data'].isNotEmpty &&
  //             barcodeNumber == null) {
  //           barcodeNumber = event['data'];
  //           widget.onScanned(barcodeNumber!);
  //         }
  //       }
  //     });
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   }
  //
  //   setState(() {
  //     isWebViewInitialized = true;
  //   });
  // }
}
