import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    var color;
    return MaterialApp(
      
        home: Stack(
          children: [
            Positioned(
              child: NativeView(
                onViewCreated: (FlutterMediapipe c) => setState(
                  () {
                    c.landMarksStream.listen(_onLandMarkStream);
                    c.platformVersion.then((content) => print(content));
                  },
                ),
              ),
            ),
            Positioned(
              top:0,
              bottom:0,
              left:0,
              right:0,
              child: Container(
                width: 300,
                height: 300,
                color: Colors.white,
                
                
              ),
              ),
              
            Positioned(
              top:170,
            
              left:0,
              right:0,
              
              child: Container(
                
                child: Text("아이를 위한 AI",
                textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, color: Colors.black),
                )
              )
                ),

                Positioned(
              bottom: 250,
              left:40,
              
              
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                
                )
              ),

              Positioned(
              bottom: 250,
              right:40,
              
              
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                
                )
              ),

              Positioned(
              bottom: 100,
              right:40,
              
              
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                
                )
              ),

              Positioned(
              bottom: 100,
              left:40,
              
              
              child: Container(
                
                width: 100,
                height: 100,
                color: Colors.grey,
                
                )
              ),

               Positioned(
              bottom: 100,
              left:40,
              
          
              child: Image(
                width: 100,
                height: 100,

                        image: AssetImage("images/google.png"),
                
                )
              ),

              Positioned(
              bottom: 110,
              right:50,
              
          
              child: Image(
                width: 80,
                height: 80,

                        image: AssetImage("images/plus.png"),
                
                )
              ),

              Positioned(
              bottom: 240,
              left:30,
              
          
              child: Image(
                width: 120,
                height: 120,

                        image: AssetImage("images/youtube.png"),
                
                )
              ),

               Positioned(
              bottom: 260,
              right: 50,
              
          
              child: Image(
                width: 80,
                height: 80,

                        image: AssetImage("images/naver.png"),
                
                )
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
