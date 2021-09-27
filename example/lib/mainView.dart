import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
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
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 170,
            left: 0,
            right: 0,
            child: Container(
              child: Text(
                "아이를 위한 AI",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
          ),
          
         
          Positioned(
              bottom: 100,
              left: 40,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 100,
                height: 100,
                child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed: () => Navigator.pushNamed(context, "/google"),
                color: Colors.grey,
                child: Image(
                width: 100,
                height: 100,
                image: AssetImage("images/google.png"),
              )),
          )),
          ),
          Positioned(
              bottom: 100,
              right: 40,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
              
                width: 100,
                height: 100,
                color: Colors.grey,
                child: Image(
                width: 80,
                height: 80,
                image: AssetImage("images/plus.png"),
              )
              ),
          )
          ),
           Positioned(
            bottom: 240,
            left: 40,
             child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
            child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed: () => Navigator.pushNamed(context, "/youtube"),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              child: Image(
                width: 100,
                height: 100,
                image: AssetImage("images/youtube.png"),
              ),
            ),
          ),
           ),
           ),
         Positioned(
            bottom: 240,
            right: 40,
             child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
            child: CupertinoButton(
              padding: EdgeInsets.all(0),
              onPressed: () => Navigator.pushNamed(context, "/web"),
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
              child: Image(
                width: 100,
                height: 100,
                image: AssetImage("images/naver.png"),
              ),
            ),
          ),
           ),
           ),
        ],
      ),
    );
  }
}
