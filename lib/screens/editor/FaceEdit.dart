import 'dart:io';
import 'dart:typed_data';

import 'package:face_editor/tools/AppUtils.dart';
import 'package:face_editor/tools/translations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'MagicBlackboard.dart';
import 'package:image/image.dart' as img;

class FaceEdit extends StatefulWidget {
  final SaveToFile storage = SaveToFile();
  File imageFile;
  img.Image _original;
  img.Image _segmentation;
  img.Image _paths;
  Uint8List _faceEdited;
  Rect boundingBox;

  @override
  _FaceEditState createState() => _FaceEditState();

  FaceEdit({
    Key key,
    @required this.imageFile,
    @required this.boundingBox,
  }) : super(key: key);
}
//with TickerProviderStateMixin
class _FaceEditState extends State<FaceEdit> {
  static const tflite = const MethodChannel('es.metodica.face_editor/tflite');
  MagicBlackboard myMagicBlackboard;
  String titleText = "Face Editor";
  BuildContext context;
  Image faceEdited;
  //var _opacityController;
  Widget _picture;
  bool _useOriginal = true;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    var strokeButtonWidth = MediaQuery.of(context).size.width / 6;

    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 16.0)),
            Text(titleText,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Roboto Light",
                    fontSize: 30.0 + AppUtils.textExtraSizeForScreen(context))),
            Padding(padding: EdgeInsets.only(top: 16.0)),

            Row(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: MediaQuery.of(context).size.width / 2,
                  child: widget._original != null ?
                  Image.memory(
                    img.encodeNamedImage(widget._original, widget.imageFile.path),
                    fit: BoxFit.fitHeight,
                  )
                      : Image.asset('assets/error.png' , fit: BoxFit.fitHeight,),
                ),
                Container(
                  height: MediaQuery.of(context).size.width / 2,
                  width: MediaQuery.of(context).size.width / 2,
                  child: FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      _useOriginal = !_useOriginal;
                      _changePicture();
                    },
                    child: _picture,
                  ),
                ),
              ],
            ),

            Container(
              color: Colors.orange,
              height: MediaQuery.of(context).size.height * AppUtils.squareRatio,
              width: MediaQuery.of(context).size.height * AppUtils.squareRatio,
              child: myMagicBlackboard != null ?

                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            alignment: Alignment.topCenter,
                            image: MemoryImage(
                              img.encodePng(widget._segmentation),
                            ),
                            fit: BoxFit.fill)),
                    child: myMagicBlackboard
                )
                : Center(child: Text("LOADING")),
            ),
            Container(
              color: Colors.white30,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xfffe0000),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xfffe0000));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xffffff00),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xffffff00));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xffa52a29),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xffa52a29));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff7f8000),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff7f8000));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xffffa500),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xffffa500));
                          },
                        )
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff00ffff),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff00ffff));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff0000fe),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff0000fe));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff00ff00),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff00ff00));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff008083),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff008083));
                          },
                        )
                      ),
                      SizedBox(
                        width: strokeButtonWidth,
                        child: FlatButton(
                          child: null,
                          color: Color(0xff81007f),
                          onPressed: () {
                            myMagicBlackboard.changeStrokeColor(Color(0xff81007f));
                          },
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
//            Padding(padding: EdgeInsets.only(top: 16.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text("CLEAN", style: TextStyle(fontSize: 18.0 + AppUtils.textExtraSizeForScreen(context)),),
                  onPressed: () {
                    setState(() {
                      myMagicBlackboard.clean();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      // CALL TO ACTION FAB
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          myMagicBlackboard.transformImage();
        },
        tooltip: Translations.of(context).text('buy_tooltip'),
        child: Icon(Icons.done, color: Colors.white),
      ), // This trailing comma makes auto-form
    );
  }

  @override
  void initState() {
    super.initState();
    _changePicture();
    var tmp = img.decodeImage(widget.imageFile.readAsBytesSync());
    tmp = img.copyCrop(tmp,
        widget.boundingBox.left.round(),
        widget.boundingBox.top.round(),
        widget.boundingBox.width.round(),
        widget.boundingBox.height.round());
    widget._original = img.copyResize(tmp, height: 256, width: 256);

    // TODO: DO NOT SAVE IMAGE
    //widget.storage.save(widget._original);

    // TODO: UNCOMMENT TO USE DEBUG FACE:
    //widget._original = img.decodeImage(File('/storage/emulated/0/Android/data/es.metodica.face_editor/files/thumbnail.png').readAsBytesSync());

    loadModel().then((val) {
      setState(() {
        myMagicBlackboard = new MagicBlackboard(new MagicBlackBoardHandler(
            (paths, image) {
              widget._faceEdited = image;
              widget._paths = paths;
              _changePicture();
            },
            (error) {
              setState(() {
                _picture = Image.asset('assets/error.png', fit: BoxFit.fitHeight,);
                debugPrint("ERROR getting editing image: " + error);
              });
            }),
            widget._segmentation,
            img.encodePng(widget._original)
        );
      });
    });
  }

  Future loadModel() async {
    var res = await tflite.invokeMethod(
        'load_model', new Map.from({"model": "assets/segmentator.tflite"}));
    print(res);

    var result = await tflite.invokeMethod<Float64List>('inference',
        new Map.from({
          "input": AppUtils.imageToByteListFloat32(widget._original, 256, 127.5, 127.5)
        }));

    widget._segmentation = AppUtils.fillImageWithFloatList(result, 256, 1, 127.5);
  }

  void _changePicture() async {
    if (widget._faceEdited == null || widget._segmentation == null) {
      _picture = Center(
          child: Column(
            children: <Widget>[
              Text("WAITING FOR NEW"),
              Text("SEGMENTATION SUBMIT")
            ],
            mainAxisAlignment: MainAxisAlignment.center,)
      );
      return;
    }

//    _opacityController.reset();
    var paintedImage = widget._faceEdited;
    if (_useOriginal) {
      paintedImage = img.encodePng(
          AppUtils.mergeImages(widget._original, widget._paths,
              img.decodeImage(widget._faceEdited))
      );
    }
    setState(() {
      _picture = Image.memory(
        paintedImage,
        fit: BoxFit.fill,
        height: MediaQuery.of(context).size.width / 2,
        width: MediaQuery.of(context).size.width / 2,
      );
//      _picture = FadeTransition(
//        opacity: new CurvedAnimation(parent: _opacityController, curve: Curves.easeIn),
//        child: Image.memory(
//          widget._faceEdited,
//          fit: BoxFit.fill,
//          height: MediaQuery.of(context).size.width / 2,
//          width: MediaQuery.of(context).size.width / 2,
//        ),
//      );
    });
//    _opacityController.forward();
    debugPrint("Uploaded!");
  }
}


class SaveToFile {
  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get localFile async {
    final path = await _localPath;
    debugPrint("LOCAL PATH TO SAVE FILE: " + path);
    return File('$path/thumbnail.png');
  }

  Future<File> save(img.Image image) async {
    final file = await localFile;
    return file..writeAsBytesSync(img.encodePng(image));
  }
}