import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe_example/mainView.dart';
import 'package:flutter_mediapipe_example/webBrowserView.dart';
import 'package:flutter_mediapipe_example/youtubeView.dart';

import 'googleView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var color;
    return MaterialApp(
      home: MainView(),
      routes: {
        "/main": (_) => MainView(),
        "/web": (_) => WebBrowserView(),
        "/youtube": (_) => YoutubeView(),
        "/google": (_) => GoogleView(),
      },
    );
  }
}
