import 'dart:io';
import 'package:archive/archive.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class DownloadAssetsManager {
  static String _dir;
  static int fileSize;
  static int downloadProgress = 0;

  static Future<bool> downloadAssets(String url, String name, void Function(double percentage) progressCallback) async {
    if (_dir == null) {
      _dir = (await getApplicationSupportDirectory()).path;
    }

    if (!await hasToDownloadAssets(name)) {
      return false;
    }

    await _downloadFile(url, '$name.zip', _dir, progressCallback);
    return true;
  }

  static Future<bool> hasToDownloadAssets(String name) async {
    if (_dir == null) {
      _dir = (await getApplicationSupportDirectory()).path;
    }

    var file = File('$_dir/$name');
    return !(await file.exists());
  }

  static Future<File> _downloadFile(String url, String filename, String dir, void Function(double percentage) progressCallback) async {
    await Dio().download(url, '$dir/$filename',
      options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),  // disable gzip
      onReceiveProgress: (received, total) {
        if (total != -1) {
          double p = received / total * 100;

          debugPrint(p.toStringAsFixed(0) + "%");
          if (progressCallback != null)
            progressCallback((p.floor() >= 99 ? 99 : p));
          if (received == total)
          {
            _unzipFile(File('$dir/$filename'), progressCallback);
          }
        }
      });
  }

  static Future<File> _unzipFile(File zippedFile, void Function(double percentage) progressCallback) async {
    var bytes = zippedFile.readAsBytesSync();
    var archive = ZipDecoder().decodeBytes(bytes);

    for (var file in archive) {
      var filename = '$_dir/${file.name}';
      if (file.isFile) {
        var outFile = File(filename);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
    zippedFile.delete();
    progressCallback(100.0);
  }
}