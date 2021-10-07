import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:sensors/sensors.dart';
import 'dart:math' as math;

import 'package:webview_flutter/webview_flutter.dart';

class WebBrowserView extends StatefulWidget {
  String url = "";

  // 생성자(Constructor)
  WebBrowserView(String inputUrl) {
    url = inputUrl;
  }

  @override
  _WebBrowserViewState createState() => _WebBrowserViewState();
}

const double EYE_BLINK_RATIO = 6.0; // 눈 깜빡임 감지(눈 가로세로) 비율
const int EYE_BLINK_LIMIT_TIME_S = 30; // 안구건조증 감지시간(초)
const int EYE_BLINK_LIMIT_PER_MINUTE = 15; // 안구건조증 분당 카운트
const int STRETCH_EYE_BLINK = 2; // 눈 스트레칭 깜빡임 횟수

const int NECK_ANGLE_LIMIT_TIME_S = 5; // 거북목 감지 시간(초)
const int NECK_ANGLE_LIMIT = 50; // 목 각도 감지 각도
const int STRETCH_NECK = 2; // 목 스트레칭 깜빡임 횟수
const int STRETCH_NECK_FAR = 50; // 목 스트레칭 먼 거리
const int STRETCH_NECK_NEAR = 160; // 목 스트레칭 가까운 거리

double faceAngle = 0.0;
double deviceAngle = 0.0;
double eyeClose = 0.0;
int eyeCount = 0;
int neckSecCount = 0;
double neckAngle = 0.0;
//
bool isEyeClose = false;
bool isTurtleNeck = false;
// 얼굴-핸드폰 거리
double eyeSize = 0.0;

bool isRunning = true;

// 거북목 일정 각도 이상 카운트
int turtleNeckCounter = 0;
// 안구건조증 눈 깜빡인 분당 카운트
int eyeBlinkPerMinute = 0;

class _WebBrowserViewState extends State<WebBrowserView> {
  @override
  void initState() {
    // 핸드폰
    accelerometerEvents.listen((AccelerometerEvent event) async {
      // Kill listener
      if (!isRunning) return;

      deviceAngle = (event.z * 1000).toInt() / 100;
      neckAngle = deviceAngle + faceAngle;

      setState(() {});
    });

    textController.addListener(() => {});

    eyeCounter();
    neckCounter();
    webRunner();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // Kill listener
    isRunning = false;
    textController.dispose();
  }

  bool isEditText = false;
  String currUrl = "https://";
  TextEditingController textController = new TextEditingController();
  WebViewController? webController;

  Future<void> webRunner() async {
    while (true) {
      await Future.delayed(Duration(milliseconds: 200));

      if (!isEditText && webController != null) {
        webController!.currentUrl().then((value) {
          if (value != null) {
            if (value.length > 27)
              textController.text = value.substring(0, 28) + "...";
            else
              textController.text = value;
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: SizedBox(
          height: 35,
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                child: CupertinoButton(
                  padding: EdgeInsets.all(0),
                  child: Icon(Icons.arrow_back_ios),
                  onPressed: () => webController!.goBack(),
                ),
              ),
              Expanded(
                child: TextFormField(
                  onTap: () {
                    isEditText = true;
                  },
                  onChanged: (value) {
                    currUrl = value;
                  },
                  onEditingComplete: () {
                    isEditText = false;
                    webController!.loadUrl(currUrl);
                  },
                  controller: textController,
                  // initialValue: currUrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: WebView(
              onWebViewCreated: (WebViewController webviewController) {
                webController = webviewController;
              },
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
            ),
          ),
          Positioned(
            bottom: 70,
            right: 15,
            width: 50,
            height: 50,
            child: NativeView(
              onViewCreated: (FlutterMediapipe c) async {
                c.landMarksStream.listen(_onLandMarkStream);
                c.platformVersion.then((content) => print(content));
                setState(() {});
              },
            ),
          ),
          Positioned(
            bottom: 30,
            right: 10,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Card(
                color: isEyeClose ? Colors.amber : Colors.greenAccent,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  Icons.remove_red_eye_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 50,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Card(
                color: isTurtleNeck ? Colors.amber : Colors.greenAccent,
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  CupertinoIcons.rectangle_on_rectangle_angled,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isModalEnable = false;
  Future<void> eyeCounter() async {
    while (true) {
      await Future.delayed(Duration(seconds: EYE_BLINK_LIMIT_TIME_S));
      if (!isModalEnable && EYE_BLINK_LIMIT_PER_MINUTE > eyeCount) {
        // 안구건조증 실행
        isModalEnable = true;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StretchModal(
                      isTurtleNeckModal: false,
                    ))).then((value) => isModalEnable = false);
      }
      eyeCount = 0;
    }
  }

  Future<void> neckCounter() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      if (NECK_ANGLE_LIMIT < neckAngle) {
        neckSecCount++;
        isTurtleNeck = true;
      } else {
        isTurtleNeck = false;
      }

      if (!isModalEnable && NECK_ANGLE_LIMIT_TIME_S < neckSecCount) {
        // 거북목 감지 실행
        isModalEnable = true;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => StretchModal(
                      isTurtleNeckModal: true,
                    ))).then((value) {
          neckSecCount = 0;
          isModalEnable = false;
        });
      }
    }
  }

  bool isEyeCountActive = false;
  Future<void> _onLandMarkStream(NormalizedLandmarkList landmarkList) async {
    // Kill listener
    if (!isRunning) return;

    // 얼굴
    double faceY = landmarkList.landmark.asMap()[18]!.y -
        landmarkList.landmark.asMap()[8]!.y;
    double faceZ = landmarkList.landmark.asMap()[18]!.z -
        landmarkList.landmark.asMap()[8]!.z;
    faceAngle = calculateDegree(a: faceZ, b: faceY);

    // 눈
    double eyeCloseX1 = landmarkList.landmark.asMap()[133]!.x -
        landmarkList.landmark.asMap()[33]!.x;
    double eyeCloseX2 = landmarkList.landmark.asMap()[133]!.y -
        landmarkList.landmark.asMap()[33]!.y;

    double eyeCloseY1 = landmarkList.landmark.asMap()[145]!.x -
        landmarkList.landmark.asMap()[159]!.x;
    double eyeCloseY2 = landmarkList.landmark.asMap()[145]!.y -
        landmarkList.landmark.asMap()[159]!.y;

    eyeClose = math.sqrt(eyeCloseX1 * eyeCloseX1 + eyeCloseY1 * eyeCloseY1) /
        math.sqrt(eyeCloseX2 * eyeCloseX2 + eyeCloseY2 * eyeCloseY2);

    isEyeClose = eyeClose >= EYE_BLINK_RATIO ? true : false;
    if (isEyeClose && !isEyeCountActive) {
      isEyeCountActive = true;
      eyeCount++;
    }
    if (!isEyeClose) isEyeCountActive = false;

    // 눈 비율
    double eyeXL = landmarkList.landmark.asMap()[133]!.x -
        landmarkList.landmark.asMap()[130]!.x;

    double eyeYL = landmarkList.landmark.asMap()[133]!.y -
        landmarkList.landmark.asMap()[130]!.y;

    double eyeXR = landmarkList.landmark.asMap()[362]!.x -
        landmarkList.landmark.asMap()[359]!.x;

    double eyeYR = landmarkList.landmark.asMap()[362]!.y -
        landmarkList.landmark.asMap()[359]!.y;

    // x           y
    // 0.010384 => 30cm
    // 0.025999 => 15cm

    // Scale up to x100
    // 1.0384 => 30cm
    // 2.5999 => 15cm

    // y = ax + b

    // 정면으로 본 상태에서 늘리는 것만

    double eyeRatioL = math.sqrt(math.pow((eyeXL), 2) + math.pow((eyeYL), 2));
    eyeRatioL *= 100;
    double eyeRatioR = math.sqrt(math.pow((eyeXR), 2) + math.pow((eyeYR), 2));
    eyeRatioR *= 100;
    // print("Listener: $eyeRatio");
    eyeSize = eyeRatioL + eyeRatioR;

    // faceAngle =  result;
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

class StretchModal extends StatefulWidget {
  final isTurtleNeckModal;

  const StretchModal({
    Key? key,
    required this.isTurtleNeckModal,
  }) : super(key: key);

  @override
  _StretchModalState createState() => _StretchModalState();
}

class _StretchModalState extends State<StretchModal> {
  int displayMode = 0;
  bool isRunning = false;
  bool isBlinkDone = false;
  bool isNeckDone = false;
  int eyeBlinkCountStretch = 0;

  bool isNeckTrigger = false;

  int neckFarCount = 0;
  int neckNearCount = 0;

  double neckTrainSize = 100;
  Color neckTrainColor = Colors.blue;

  Future<void> runner() async {
    bool isClosedEye = false;

    while (isRunning) {
      await Future.delayed(Duration(milliseconds: 100));
      // 목 동작
      if (widget.isTurtleNeckModal) {
        neckTrainSize = eyeSize * 3;
        print(neckTrainSize);

        if (!isNeckTrigger) {
          isNeckTrigger = true;
          // 조건 맞을 시 종료
          if (neckFarCount >= STRETCH_NECK && neckNearCount >= STRETCH_NECK) {
            isNeckDone = true;
            displayMode = 10;
            setState(() {});
          }

          if (STRETCH_NECK_FAR >= neckTrainSize) {
            neckTrainColor = Colors.greenAccent;
            neckFarCount++;
          } else if (STRETCH_NECK_NEAR <= neckTrainSize) {
            neckTrainColor = Colors.greenAccent;
            neckNearCount++;
          }
        }

        if (isNeckTrigger &&
            STRETCH_NECK_FAR < neckTrainSize &&
            STRETCH_NECK_NEAR > neckTrainSize) {
          isNeckTrigger = false;
          neckTrainColor = Colors.blue;
        }

        // STRETCH_NECK = 2; // 목 스트레칭 깜빡임 횟수
        // STRETCH_NECK_FAR = 190; // 목 스트레칭 먼 거리
        // STRETCH_NECK_NEAR

      }
      // 눈 깜빡임 동작
      else {
        if (!isClosedEye && isEyeClose) {
          isClosedEye = true;
          eyeBlinkCountStretch++;
        }
        if (!isEyeClose) isClosedEye = false;

        // 조건 맞을 시 종료
        if (eyeBlinkCountStretch >= STRETCH_EYE_BLINK) {
          isBlinkDone = true;
          displayMode = 10;
          setState(() {});
        }
      }

      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    isRunning = true;
    runner();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    isRunning = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (displayMode == 0) intro(),
          if (displayMode == 1) neck1(),
          if (displayMode == 4) eye1(),
          if (displayMode == 10) complete(),
        ],
      ),
    ));
  }

  Widget intro() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Image(image: AssetImage("images/siren.png")),
          ),
          Text(
            widget.isTurtleNeckModal ? "거북목을\n진단하였습니다" : "안구건조증을\n진단하였습니다",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 250,
            child: Image(
                image: AssetImage(widget.isTurtleNeckModal
                    ? "images/turtleNeck.jpeg"
                    : "images/dryeye.png")),
          ),
          SizedBox(height: 50),
          CupertinoButton(
            color: Color.fromRGBO(52, 211, 123, 1.0),
            child: Text("시작"),
            onPressed: () {
              eyeBlinkCountStretch = 0;
              neckFarCount = 0;
              neckNearCount = 0;
              widget.isTurtleNeckModal ? displayMode = 1 : displayMode = 4;
              setState(() {});
            },
          ),
          SizedBox(height: 30),
        ],
      );

  Widget neck1() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "스트레칭",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            "팔을 앞뒤로 움직여\n원의 크리를 바꿔보세요 ($STRETCH_NECK)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          SizedBox(
            height: 300,
            width: 300,
            // 원 추가
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: neckTrainSize,
                  height: neckTrainSize,
                  child: Card(
                    color: neckTrainColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          CupertinoButton(
            color: Color.fromRGBO(52, 211, 123, 1.0),
            child: Text("시작"),
            onPressed: () {
              displayMode = 10;
              setState(() {});
            },
          ),
        ],
      );

  Widget complete() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "스트레칭을\n완료했습니다",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          SizedBox(
            width: 250,
            child: Image(image: AssetImage("images/yoga.png")),
          ),
          SizedBox(height: 50),
          CupertinoButton(
            color: Color.fromRGBO(52, 211, 123, 1.0),
            child: Text("닫기"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );

  Widget eye1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "천천히 눈을\n$STRETCH_EYE_BLINK번 깜빡이세요",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 50),
        SizedBox(
          width: 250,
          child: Image(
              image: AssetImage(
                  isEyeClose ? "images/eye2.png" : "images/eye1.png")),
        ),
        SizedBox(height: 50),
        CupertinoButton(
          color: Color.fromRGBO(52, 211, 123, 1.0),
          child: Text("시작"),
          onPressed: () {
            displayMode = 10;
            setState(() {});
          },
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
