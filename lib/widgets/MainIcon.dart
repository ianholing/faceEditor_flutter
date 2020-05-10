import 'package:face_editor/tools/AppUtils.dart';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';

class MainIcon extends StatelessWidget {
  final double textSize;

  const MainIcon({Key key, @required this.textSize}) : super(key: key);

  @override
  Widget build(BuildContext context) => Hero(
    tag: "main_icon",
    child: Container(
      margin: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: Color.fromARGB(100, 0, 0, 0),
            blurRadius: 15.0,
          )],
        ),
        child: Image.asset("assets/logo.png",
            fit: BoxFit.fill,
          ),
      ),
  );
}