import 'package:face_editor/models/layer.dart';
import 'package:face_editor/tools/AppUtils.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ImageAccess {
  Image imagen;
  Uint8List bytes;
}

class MagicBlackBoardHandler {
  final void Function(img.Image, Uint8List) newImageCallback;
  final void Function(String) errorCallback;

  MagicBlackBoardHandler(this.newImageCallback, this.errorCallback);
}

class MagicBlackboard extends StatefulWidget {
  ImageAccess aImagen = new ImageAccess();
  Color strokeColor = Color(0xffffff00);
  _MagicBlackboardState _actualState;
  MagicBlackBoardHandler handler;
  img.Image baseImage;
  Uint8List realImage;
  ui.Image pBaseImage;
  double _containerSize = -1;


  MagicBlackboard(this.handler, this.baseImage, this.realImage);

  void clean() {
    _actualState.stateClean();
  }

  void transformImage() {
    _actualState.transformImage();
  }

  void changeSegmentation(img.Image segmentation) {
    baseImage = segmentation;
    _actualState._getBackgroundImage();
  }

  void changeStrokeColor(Color newColor) {
    _actualState.setState(() {
      _actualState._saveActualPath();
      strokeColor = newColor;
    });
  }

  @override
  _MagicBlackboardState createState() {
    _actualState = new _MagicBlackboardState();
    return _actualState;
  }
}

class _MagicBlackboardState extends State<MagicBlackboard>
    with TickerProviderStateMixin {
  List<Offset> points;
  List<DrawLayer> cachePaths = new List<DrawLayer>();
  List<List<Offset>> paths = new List<List<Offset>>();
  MagicBlackboardPainter _mypainter;

  void stateClean() {
    setState(() {
      cachePaths = new List<DrawLayer>();
      paths = new List<List<Offset>>();
    });
  }

  void _saveActualPath() {
    if (cachePaths == null)
      cachePaths = List<DrawLayer>();
    cachePaths.add(new DrawLayer(widget.strokeColor, paths));
    paths = new List<List<Offset>>();
  }

  Future<Null> transformImage() async {
    try {
      debugPrint("START TRANSFORMING PROCESS");
      await _mypainter.capturePng();
      _saveActualPath();

      // Add Background segmentation to painted segmentation
      var decodedImage = img.decodeImage(widget.aImagen.bytes);
      decodedImage = img.copyResize(decodedImage, width: widget.baseImage.width, height: widget.baseImage.height);
      final mergedImage = img.Image(widget.baseImage.width, widget.baseImage.height);
      img.copyInto(mergedImage, widget.baseImage, blend: false);
      img.copyInto(mergedImage, decodedImage, blend: true);


      var request = new http.MultipartRequest(
          "POST", Uri.parse(AppUtils.baseUrl + "magic"));
      request.fields['segmentation'] = base64.encode(img.encodePng(mergedImage));
      request.fields['original'] = base64.encode(widget.realImage);

//      // TODO: Make it work with Bytes, quickest way, but got problems with encoding
//      request.files.add(new http.MultipartFile.fromBytes('original', widget.aImagen.bytes));
//      request.files.add(new http.MultipartFile.fromBytes('original', widget.aImagen.bytes));
      request.send().then((response) {
        if (response.statusCode == 200)
          _returnPicture(decodedImage, response);
        else
          widget.handler.errorCallback('Failed to load post');
      });

//      //FirebaseAnalytics().logEvent(name: "draw2art_stroke");
    } catch (e) {
      widget.handler.errorCallback('e.toString()');
      debugPrint(e.toString());
    }
  }

  Future<Null> _returnPicture(img.Image paths, http.StreamedResponse response) async {
    Uint8List _actualImageData = await response.stream.toBytes();
    widget.handler.newImageCallback(paths, _actualImageData);

    //TODO: USE A BLACKBOARD HANDLER TO RETURN THE IMAGE HERE
    debugPrint("Uploaded!");
  }

  // Not used
  void _tapDown(TapDownDetails details) {
    debugPrint('tapDown');
  }

  // User tap one point
  void _tapUp(TapUpDetails details) {
    debugPrint('tapUp');
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      // translation.y have the offset from the top of the screen to the "canvas".

      points = [
        new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy - translation.y)
      ];
      points.add(new Offset(points[points.length-1].dx, points[points.length-1].dy));
      paths.add(points);
    });
  }

  // Not used
  void _tapCancel() {
    debugPrint('tapCancel');
  }

  // User touch and drag over the screen
  void _panStart(DragStartDetails details) {
    debugPrint('panStart');
    setState(() {
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      points = [
        new Offset(details.globalPosition.dx - translation.x,
            details.globalPosition.dy - translation.y)
      ];
      paths.add(points);
      // Add here to refresh the screen. If paths.add is only in panEnd
      // only update the screen when finger is up
    });
  }

  // User drag over screen
  void _panUpdate(DragUpdateDetails details) {
    setState(() {
      //debugPrint('panUpdate');
      var object = this.contexto.findRenderObject();
      var translation = object?.getTransformTo(null)?.getTranslation();
      points.add(new Offset(details.globalPosition.dx - translation.x,
          details.globalPosition.dy - translation.y));
    });
  }

  void _panEnd(DragEndDetails details) {
    // Comment this to allow more than one path per layer
    //_saveActualPath();
    debugPrint('panEnd');
  }

  BuildContext contexto;

  @override
  Widget build(BuildContext context) {
    contexto = context;
    if (widget._containerSize < 0)
      widget._containerSize = MediaQuery
        .of(context)
        .size
        .width * AppUtils.squareRatio * MediaQuery.of(context).devicePixelRatio;
    if (_mypainter != null && widget.pBaseImage == null) _getBackgroundImage();

    _mypainter = new MagicBlackboardPainter(
      lineColor: widget.strokeColor,
      aImg: widget.aImagen,
      baseImage: widget.pBaseImage,
      strokeWidth: 1.0,
      exportImageWidth: AppUtils.modelImageSize.floor(),
      exportImageHeight: AppUtils.modelImageSize.floor(),
      cachePaths: cachePaths,
      paths: paths,
    );
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
            height: widget._containerSize,
            width: widget._containerSize,
            child: GestureDetector(
              //  behavior: HitTestBehavior.translucent,
              onTap: () {
                debugPrint('tap');
              },
              onTapDown: _tapDown,
              onTapUp: _tapUp,
              onTapCancel: _tapCancel,
              onPanStart: _panStart,
              onPanEnd: _panEnd,
              onPanUpdate: _panUpdate,
              child: Container(
                color: Colors.transparent,
                height: widget._containerSize,
                width: widget._containerSize,
                child: new CustomPaint(
                  size: Size(widget._containerSize, widget._containerSize),
                  foregroundPainter: _mypainter,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    stateClean();
  }

  void _getBackgroundImage() async {
    var _w = _mypainter.getCanvasRealSize().width.floor();
    var codec = await ui.instantiateImageCodec(img.encodeJpg(widget.baseImage), targetWidth: _w-1, targetHeight: _w-1);
    var frame = await codec.getNextFrame();
    widget.pBaseImage = frame.image;
    setState(() {});  // JUST REFRESH CANVAS
  }
}

class MagicBlackboardPainter extends CustomPainter {
  Color lineColor; //Line color

  ImageAccess aImg;
  ui.Image baseImage;
  double strokeWidth;
  int exportImageWidth;
  int exportImageHeight;
  List<DrawLayer> cachePaths; // paths to draw
  List<List<Offset>> paths; // paths to draw
  ui.Picture _apiPicture;
  Size _canvasRealSize;

  MagicBlackboardPainter(
      {this.lineColor,
        this.aImg,
        this.baseImage,
        this.strokeWidth,
        this.cachePaths,
        this.paths,
        this.exportImageWidth,
        this.exportImageHeight});

  Future<void> capturePng() async {
    //ui.Image img = await _apiPicture.toImage(exportImageWidth, exportImageWidth);
    ui.Image img = await _apiPicture.toImage(_canvasRealSize.width.floor(), _canvasRealSize.height.floor());
    ByteData tmp = await img.toByteData(format: ui.ImageByteFormat.png);
    aImg.bytes = tmp.buffer.asUint8List();
  }

  Size getCanvasRealSize() {
    return _canvasRealSize;
  }

  @override
  void paint(Canvas canvasFinal, Size size) {
    _canvasRealSize = size;


    if (baseImage != null)
      canvasFinal.drawImage(baseImage, Offset.zero, Paint());

    final recorder = new ui.PictureRecorder(); // dart:ui
    final canvas = new Canvas(recorder);

    cachePaths.forEach((layer) {
      _addPathsToCanvas(canvas, layer.path, layer.color);
    });
    _addPathsToCanvas(canvas, paths, lineColor);

    if ((paths == null || paths.isEmpty) &&
        (cachePaths == null || cachePaths.isEmpty)) return;

    // Storing image
    _apiPicture = recorder.endRecording();
    canvasFinal.drawPicture(_apiPicture);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //return paths != null;
    return true;
  }

  void _addPathsToCanvas(
      Canvas canvas, List<List<Offset>> paths, Color lineColor) {
    for (List<Offset> points in paths) {
      if (points.length > 1) {
        Path path = Path();
        Offset origin = points[0];
        path.moveTo(origin.dx, origin.dy);
        for (Offset o in points) {
          path.lineTo(o.dx, o.dy);
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.fill
            ..strokeWidth = this.strokeWidth,
        );

        // TODO FILL POLYGONS
      } else {
        canvas.drawPoints(
          ui.PointMode.points,
          points,
          Paint()
            ..color = lineColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = this.strokeWidth,
        );
      }
    }
  }
}