import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:face_editor/tools/DownloadAssetsManager.dart';
import 'package:face_editor/widgets/MainIcon.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String modelUrl = 'http://www.metodica.es/segmentator.zip';
  String modelAsset = 'segmentator.tflite';
  bool needDownload = false;
  Widget modelDownloadProgress = Text("Loading...");
  LiquidLinearProgressIndicator liquidProgress;

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  checkModels() async {
    needDownload = await DownloadAssetsManager.hasToDownloadAssets(modelAsset);
    debugPrint("Download model: " + (needDownload ? "YES" : "NO"));
    startTime();
  }

  void navigationPage() {
    if (!needDownload) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            settings: RouteSettings(name: "Home"),
            builder: (context) => MyApp()
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkModels();

    liquidProgress = LiquidLinearProgressIndicator(
        value: 0,
        valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
        backgroundColor: Colors.white,
        borderColor: Colors.blue,
        borderWidth: 2.0,
        borderRadius: 12.0,
        direction: Axis.horizontal,
        center: modelDownloadProgress
    );

    DownloadAssetsManager.downloadAssets(modelUrl, modelAsset, (percentage) {
      setState(() {
        needDownload = (percentage != 100.0);
        if (!needDownload) {
          startTime();
          return;
        }

        int p = percentage.floor();
        modelDownloadProgress = Text("Downloading model $modelAsset... $p%");
        liquidProgress = LiquidLinearProgressIndicator(
            value: percentage / 100,
            valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
            backgroundColor: Colors.white,
            borderColor: Colors.blue,
            borderWidth: 2.0,
            borderRadius: 12.0,
            direction: Axis.horizontal,
            center: modelDownloadProgress
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          new Container(
            decoration: BoxDecoration(
//              image: DecorationImage(
//                image: AssetImage("assets/background.jpg"),
//                colorFilter: ColorFilter.mode(
//                    Colors.black.withAlpha(70), BlendMode.darken),
//                fit: BoxFit.cover,
//              ),

              gradient: LinearGradient(
                  colors: [Colors.white, Colors.blue],
                  begin: const FractionalOffset(0.0, 1.0),
                  end: const FractionalOffset(0.5, 0.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.mirror
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: SizedBox(
                  height: 220.0,
                  child: MainIcon(
                    textSize: 55.0,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(12.0)),
              Text("AI FACE EDITOR",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontFamily: "Roboto Black",
                      fontSize: 30.0)),
              Padding(padding: EdgeInsets.all(16.0)),
              needDownload ?
                Container(
                  padding: EdgeInsets.all(16.0),
                  height: 128,
                  child: Center(
                    child: liquidProgress,
                  ),
                )
                :
                Padding(padding: EdgeInsets.all(64.0))
            ],
          ),
        ],
      ),
    );
  }
}
