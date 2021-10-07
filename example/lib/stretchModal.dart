// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// class StretchModal extends StatefulWidget {
//   final isTurtleNeck;

//   const StretchModal({
//     Key? key,
//     required this.isTurtleNeck,
//   }) : super(key: key);

//   @override
//   _StretchModalState createState() => _StretchModalState();
// }

// class _StretchModalState extends State<StretchModal> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 300,
//       height: 300,
//       child: Card(
//         child: Column(
//           children: [
//             SizedBox(
//               width: 100,
//               child: Image(image: AssetImage("images/siren.png")),
//             ),
//             Text("거북목을\n진단하였습니다"),
//             SizedBox(
//               width: 300,
//               child: Image(image: AssetImage("images/turtleNeck.jpeg")),
//             ),
//             CupertinoButton(
//               color: Color.fromRGBO(52, 211, 123, 1.0),
//               child: Text("시작"),
//               onPressed: () => {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
