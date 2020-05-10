import 'package:face_editor/screens/start/splash.dart';
import 'package:face_editor/tools/translations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/detector/FacePage.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();
void main() => runApp(new MyApp(useSplash: true,));

class MyApp extends StatelessWidget {
  final bool useSplash;

  MyApp({
    Key key,
    this.useSplash = false,
  }) : super(key: key);

  static MaterialLocalizations of(BuildContext context) {
    return Localizations.of<MaterialLocalizations>(
        context, MaterialLocalizations);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    Widget launchWidget = new SplashScreen();
    if (ios || !useSplash) launchWidget = new FacePage();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      localizationsDelegates: [
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('es', 'ES'), // Spanish
      ],
      home: launchWidget,
    );
  }
}