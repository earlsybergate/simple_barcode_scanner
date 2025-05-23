import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:simple_barcode_scanner/directory_path_service.dart';

abstract class WindowsWebViewService {
  static Webview? _webView;

  static Future<void> initialize() async {
    try {
      final temporaryDirectoryPath =
          await DirectoryPathService.getTemporaryDirectoryPath();

      _webView = await WebviewWindow.create(
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
      _webView?.launch(url);
    } on Exception {}
  }

  static void registerJavascriptMessageHandler({
    required String channelName,
    required void Function(String name, dynamic body) onMessage,
  }) {
    try {
      _webView?.registerJavaScriptMessageHandler(
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
      _webView?.unregisterJavaScriptMessageHandler(channelName);
    } on Exception {
      rethrow;
    }
  }
}
