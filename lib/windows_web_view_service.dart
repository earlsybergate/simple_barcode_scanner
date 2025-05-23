import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:simple_barcode_scanner/directory_path_service.dart';

abstract class WindowsWebViewService {
  static Webview? webView;

  static Future<void> initialize() async {
    try {
      final temporaryDirectoryPath =
          await DirectoryPathService.getTemporaryDirectoryPath();

      webView = await WebviewWindow.create(
        configuration: CreateConfiguration(
          userDataFolderWindows: '$temporaryDirectoryPath/webview',
          titleBarHeight: 0,
        ),
      );
    } on Exception {
      rethrow;
    }
  }

  static Future<bool> isWebViewAvailable() async =>
      WebviewWindow.isWebviewAvailable();

  static void launch(String url) {
    try {
      webView?.launch(url);
    } on Exception {
      rethrow;
    }
  }

  static void registerJavascriptMessageHandler({
    required String channelName,
    required void Function(String name, dynamic body) onMessage,
  }) {
    try {
      webView?.registerJavaScriptMessageHandler(
        channelName,
        onMessage,
      );
    } on Exception {
      rethrow;
    }
  }

  static void unregisterJavascriptMessageHandler({
    required String channelName,
  }) {
    try {
      webView?.unregisterJavaScriptMessageHandler(channelName);
    } on Exception {
      rethrow;
    }
  }

  static void close() {
    try {
      webView?.close();
    } on Exception {
      rethrow;
    }
  }
}
