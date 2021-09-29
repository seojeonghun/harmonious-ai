import 'package:flutter/material.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;

import 'package:webview_flutter/webview_flutter.dart';

class YoutubeView extends StatefulWidget {
  const YoutubeView({Key? key}) : super(key: key);

  @override
  _YoutubeViewState createState() => _YoutubeViewState();
}

class _YoutubeViewState extends State<YoutubeView> {
  double faceAngle = 0.0;
  double deviceAngle = 0.0;

  @override
  void initState() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      deviceAngle = (event.z * 1000).toInt() / 100;
      print("faceAngle: $faceAngle\ndeviceAngle: $deviceAngle");
      setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: WebView(
              initialUrl: "https://www.youtube.com/",
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
          Positioned(
            width: 10,
            height: 10,
            child: NativeView(
              onViewCreated: (FlutterMediapipe c) => setState(
                () {
                  c.landMarksStream.listen(_onLandMarkStream);
                  c.platformVersion.then((content) => print(content));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLandMarkStream(NormalizedLandmarkList landmarkList) {
    //   landmarkList.landmark.asMap().forEach((int i, NormalizedLandmark value) {
    //    // print('Index: $i \n' + '$value');
    //   });

    //   print("8번 x");
    //   print(landmarkList.landmark.asMap()[8]!.x);
    //   print("8번 y");
    //   print(landmarkList.landmark.asMap()[8]!.y);
    //   print("8번 z");
    //   print(landmarkList.landmark.asMap()[8]!.z);
    //   print(" ");

    //   print("18번 x");
    //   print(landmarkList.landmark.asMap()[18]!.x);
    //   print("18번 y");
    //   print(landmarkList.landmark.asMap()[18]!.y);
    //   print("18번 z");
    //   print(landmarkList.landmark.asMap()[18]!.z);
    //   print(" ");
    double yCal = landmarkList.landmark.asMap()[18]!.y -
        landmarkList.landmark.asMap()[8]!.y;
    double zCal = landmarkList.landmark.asMap()[18]!.z -
        landmarkList.landmark.asMap()[8]!.z;
    double result = calculateDegree(a: zCal, b: yCal);

    faceAngle = result;
  }

  /// ### tan(a/b)로 사용
  ///  - a: 분자
  ///  - b: 분모
  double calculateDegree({
    required double a,
    required double b,
  }) {
    double rad = math.atan2(a, b);
    double degree = rad * 180 / math.pi; // 라디안 -> 디그리 변환

    return degree;
  }
}
