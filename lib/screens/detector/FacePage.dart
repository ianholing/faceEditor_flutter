import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:face_editor/screens/editor/FaceEdit.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

import 'FacePainter.dart';

class FacePage extends StatefulWidget {
  @override
  _FacePageState createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Rect> _faces;
  bool isLoading = false;
  ui.Image _image;
  Rect _extraPercentage = new Rect.fromLTRB(0.1, 0.4, 0.1, 0.2);


  _getImageAndDetectFaces() async {
    //final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      isLoading = true;
    });
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> faces = await faceDetector.processImage(image);
    if (mounted) {
      await _loadImage(imageFile);
      setState(() {
        _imageFile = imageFile;
        //ExtendedImage image = ExtendedImage.file(imageFile);
        _faces = new List<Rect>();
        for (var i = 0; i < faces.length; i++) {
          var topExtra = (faces[i].boundingBox.bottom - faces[i].boundingBox.top) * -_extraPercentage.top;
          var bottomExtra = (faces[i].boundingBox.bottom - faces[i].boundingBox.top) * _extraPercentage.bottom;
          var leftExtra = (faces[i].boundingBox.right - faces[i].boundingBox.left) * -_extraPercentage.left;
          var rightExtra = (faces[i].boundingBox.right - faces[i].boundingBox.left) * _extraPercentage.right;
          _faces.add(new Rect.fromLTRB(
              faces[i].boundingBox.left+leftExtra > 0 ? faces[i].boundingBox.left+leftExtra : 0,
              faces[i].boundingBox.top+topExtra > 0 ? faces[i].boundingBox.top+topExtra : 0,
              faces[i].boundingBox.right + rightExtra > _image.width ? _image.width : faces[i].boundingBox.right + rightExtra,
              faces[i].boundingBox.bottom + bottomExtra > _image.height ? _image.height : faces[i].boundingBox.bottom + bottomExtra
          ));

          //ImageEditor.editImage(image: _image.toByteData(format: ImageByteFormat.rawRgba), imageEditorOption: null);
        }
      });
    }
  }

  _loadImage(File file) async {
    final data = await file.readAsBytes();
    await decodeImageFromList(data).then(
          (value) => setState(() {
        _image = value;
        isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : (_imageFile == null)
          ? Center(child: Text('No image selected'))
          : Center(
        child: FittedBox(
          child: SizedBox(
            width: _image.width.toDouble(),
            height: _image.height.toDouble(),
            child: Stack(
              children: <Widget>[
                Image.file(_imageFile),
                CustomPaint(painter: FacePainter(_image, _faces)),
                Stack(
                  children: _faces.map<Widget>((f) => Positioned(
                    left: f.left,
                    top: f.top,
                    child: Container(
                      child: MaterialButton(
                        height: f.bottom-f.top,
                        minWidth: f.right-f.left,
                        onPressed: (){
                          debugPrint("PRESSED");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(name: "Form", isInitialRoute: false),
                                builder: (BuildContext context) =>
                                    FaceEdit(imageFile: _imageFile, boundingBox: f),
                              ));
                        },
                      ),
                    ),
                  ),
                  ).toList(),
                )
              ],
            )
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}