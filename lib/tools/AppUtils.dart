import 'dart:typed_data';

import 'package:face_editor/tools/translations.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class AppUtils {
//  static final String baseUrl = "http://192.168.1.59:5001/";
  static final String baseUrl = "https://mairo.metodica.es:5001/";
  static final String modelName = "megamask_v2.tflite";
  static final double squareRatio = 0.4;
  static final double modelImageSize = 256;

  static Future<Null> showAboutDialog(BuildContext context) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              Translations.of(context).text('drawer_about_title'),
              style: TextStyle(
                fontFamily: "Roboto Black",
              ),
              textAlign: TextAlign.center
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(4.0)),
                Image(image: new AssetImage("assets/about_gif.gif"), height: 200.0,),
                Padding(padding: EdgeInsets.all(16.0)),
                Text(
                    Translations.of(context).text('drawer_about_1'),
                    style: TextStyle(
                      fontFamily: "Roboto Light",
                    )
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                Text(
                    Translations.of(context).text('drawer_about_2'),
                    style: TextStyle(
                      fontFamily: "Roboto Light",
                    )
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<Null> showAppDialog(BuildContext context, String title, String body, String button) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(button),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static double textExtraSizeForScreen(BuildContext context) {
    return (MediaQuery.of(context).size.width - 410) * 0.12;
  }

  static Float32List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return buffer;
  }

  static img.Image fillImageWithFloatList(Float64List data, int inputSize, double mean, double std) {
    img.Image segmentation = img.Image.rgb(inputSize, inputSize);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var r = ( data[pixelIndex+0] + mean ) * std;
        var g = ( data[pixelIndex+1] + mean ) * std;
        var b = ( data[pixelIndex+2] + mean ) * std;
        pixelIndex += 3;
        segmentation.setPixelRgba(j, i, r.floor(), g.floor(), b.floor());
      }
    }
    return segmentation;
  }

  static img.Image fillImageWithIntList(Int32List data, int inputSize) {
    img.Image segmentation = img.Image.rgb(inputSize, inputSize);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var r = ( data[pixelIndex+0]);
        var g = ( data[pixelIndex+1]);
        var b = ( data[pixelIndex+2]);
        pixelIndex += 3;
        segmentation.setPixelRgba(j, i, r, g, b);
      }
    }
    return segmentation;
  }

  static img.Image mergeImages(img.Image background, img.Image mask, img.Image stamp) {
    var returnImage = img.Image(background.width, background.height);
    //background = img.copyResize(background, width: returnImage.width, height: returnImage.height);
    mask = img.copyResize(mask, width: returnImage.width, height: returnImage.height);
    stamp = img.copyResize(stamp, width: returnImage.width, height: returnImage.height);

    for (var i = 0; i < returnImage.height; i++) {
      for (var j = 0; j < returnImage.width; j++) {
        var pixel = mask.getPixel(j, i);
        if (img.getAlpha(pixel) == 0)
          returnImage.setPixel(j, i, background.getPixel(j, i));
        else
          returnImage.setPixel(j, i, stamp.getPixel(j, i));
      }
    }
    return returnImage;
  }
}