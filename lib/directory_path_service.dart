import 'package:path_provider/path_provider.dart' as path_provider;

class DirectoryPathService {
  static Future<String> getTemporaryDirectoryPath() async {
    try {
      final temporaryDirectory = await path_provider.getTemporaryDirectory();

      return temporaryDirectory.path;
    } on Exception {
      rethrow;
    }
  }

  static Future<String> getDownloadsDirectoryPath() async {
    try {
      final directory = await path_provider.getDownloadsDirectory();

      return directory?.absolute.path ?? '';
    } on Exception {
      rethrow;
    }
  }

  static Future<String> getApplicationDocumentsDirectoryPath() async {
    try {
      final directory = await path_provider.getApplicationDocumentsDirectory();

      return directory.absolute.path;
    } on Exception {
      rethrow;
    }
  }

  static Future<String> getApplicationSupportDirectoryPath() async {
    try {
      final directory = await path_provider.getApplicationSupportDirectory();

      return directory.absolute.path;
    } on Exception {
      rethrow;
    }
  }
}
