import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

class DisplayVideo extends StatefulWidget {
  final List<String> list;
  DisplayVideo({Key key, this.list}) : super(key: key);

  @override
  _DisplayVideoState createState() => _DisplayVideoState();
}

class _DisplayVideoState extends State<DisplayVideo> {
  bool isPlaying = false;
  Timer _timer;
  int _currentFrame = 0;
  int _start = 33;
  void startTimer(){
    const oneSec = const Duration(milliseconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
          (){
        if (isPlaying){
          if (_start == 0){
            if(_currentFrame < widget.list.length - 1){
              _currentFrame += 1;
            }else{
              isPlaying = false;
              timer.cancel();
              _start = 33;
              _currentFrame = 0;
            }
            _start = 33;
          }
          else{
            _start -= 1;
          }
        }
        else {
          timer.cancel();
        }
      }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: Image.file(
              File(widget.list[_currentFrame]),
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: InkWell(
              onTap: (){
                if (!isPlaying){
                  startTimer();
                  setState(() {
                    isPlaying = true;
                  });
                }else{
                  setState(() {
                    isPlaying = false;
                  });
                }
              },
              child: Container(
                height: 75,
                width: 75,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white, width: 2)
                ),
                child: (!isPlaying)? Icon(CupertinoIcons.play_arrow_solid):Icon(CupertinoIcons.pause_solid),
//
              ),
            )
//            FloatingActionButton(
//              backgroundColor: Colors.white70,
//              child: (!isPlaying)? Icon(CupertinoIcons.play_arrow_solid):Icon(Icons.pause),
//              onPressed: (){
//                if (!isPlaying){
//                  startTimer();
//                  setState(() {
//                    isPlaying = true;
//                  });
//                }else{
//                  setState(() {
//                    isPlaying = false;
//                  });
//                }
//              },
//            ),
          ),
        ],
      ),
    );
  }
}
