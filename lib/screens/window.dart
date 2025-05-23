import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:simple_barcode_scanner/constant.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:webview_windows/webview_windows.dart';

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
  late final WebviewController controller;
  bool isPermissionGranted = false;
  bool isWebViewInitialized = false;

  @override
  void initState() {
    super.initState();

    controller = WebviewController();

    _checkCameraPermission().then((granted) {
      isPermissionGranted = granted;

      initPlatformState(controller: controller);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppBar(controller, context, widget.cancelButtonText),
      body: isWebViewInitialized ? Webview(
        controller,
        permissionRequested: (url, permissionKind, isUserInitiated) =>
            _onPermissionRequested(
              url: url,
              kind: permissionKind,
              isUserInitiated: isUserInitiated,
              context: context,
              isPermissionGranted: isPermissionGranted,
            ),

      ) : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Checks if camera permission has already been granted
  Future<bool> _checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  Future<WebviewPermissionDecision> _onPermissionRequested(
      {required String url,
      required WebviewPermissionKind kind,
      required bool isUserInitiated,
      required BuildContext context,
      required bool isPermissionGranted}) async {
    final WebviewPermissionDecision? decision;
    if (!isPermissionGranted) {
      decision = await showDialog<WebviewPermissionDecision>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission requested'),
          content:
              Text('\'${kind.name}\' permission is require to scan qr/barcode'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, WebviewPermissionDecision.deny);
                isPermissionGranted = false;
              },
              child: const Text('Deny'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, WebviewPermissionDecision.allow);
                isPermissionGranted = true;
              },
              child: const Text('Allow'),
            ),
          ],
        ),
      );
    } else {
      decision = WebviewPermissionDecision.allow;
    }

    return decision ?? WebviewPermissionDecision.none;
  }

  String getAssetFileUrl({required String asset}) {
    final assetsDirectory = p.join(p.dirname(Platform.resolvedExecutable),
        'data', 'flutter_assets', asset);
    return Uri.file(assetsDirectory).toString();
  }

  Future<void> initPlatformState(
      {required WebviewController controller}) async {
    String? barcodeNumber;

    try {
      await controller.initialize();
      await controller
          .loadUrl(getAssetFileUrl(asset: PackageConstant.barcodeFilePath));

      /// Listen to web to receive barcode
      controller.webMessage.listen((event) {
        if (event['methodName'] == "successCallback") {
          if (event['data'] is String &&
              event['data'].isNotEmpty &&
              barcodeNumber == null) {
            barcodeNumber = event['data'];
            widget.onScanned(barcodeNumber!);
          }
        }
      });
    } catch (e) {
      debugPrint("Error: $e");
    }

    setState(() {
      isWebViewInitialized = true;
    });
  }

  _buildAppBar(
    WebviewController controller,
    BuildContext context,
    String cancelButtonText,
  ) {
    if (widget.appBarTitle == null && widget.barcodeAppBar == null) {
      return null;
    }
    if (widget.barcodeAppBar != null) {
      return AppBar(
        title: widget.barcodeAppBar?.appBarTitle != null
            ? Text(widget.barcodeAppBar!.appBarTitle!)
            : null,
        centerTitle: widget.barcodeAppBar?.centerTitle ?? false,
        actions: [
          if (widget.barcodeAppBar!.enableBackButton == true)
            TextButton(
              onPressed: () {
                /// send close event to web-view
                controller.postWebMessage(json.encode({"event": "close"}));
                Navigator.pop(context);
              },
              child: Text(cancelButtonText),
            ),
        ],
        automaticallyImplyLeading: false,
      );
    }
    return AppBar(
      title: Text(widget.appBarTitle ?? kScanPageTitle),
      centerTitle: widget.centerTitle,
      leading: IconButton(
        onPressed: () {
          /// send close event to web-view
          controller.postWebMessage(json.encode({"event": "close"}));
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back_ios),
      ),
    );
  }
}
