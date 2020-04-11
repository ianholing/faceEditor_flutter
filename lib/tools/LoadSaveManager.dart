import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class LoadSaveManager {
  Future<Directory> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<File> save(img.Image image, String filename) async {
    final dir = await _localPath;
    debugPrint("LOCAL PATH TO SAVE FILE: " + dir.path + "/" + filename);
    final file = File('${dir.path}/$filename');
    return file..writeAsBytesSync(img.encodePng(image));
  }

  Future<List<FileSystemEntity>> getSavedFiles() async {
    final dir = await _localPath;
    return dir.listSync();
  }

  Future<String> selectSavedFilesDialog(BuildContext context) async {
    var files = await getSavedFiles();
    List<Widget> optionsList = files.map((file) =>
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, file.path);
          },
          child: Text(file.path),
        )).toList();
    return await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Departments '),
            children: optionsList,
          );
        });
  }

  void saveFileDialog(img.Image file, BuildContext context) {
    showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        String filename = '';
        return AlertDialog(
          title: Text('Enter segmentation file name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'File Name', hintText: 'eg. Father'),
                    onChanged: (value) {
                      filename = value;
                    },
                  ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                save(file, filename);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}