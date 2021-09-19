import 'dart:io';
import 'dart:async';
import 'package:cameratricks/playVid.dart';
import 'package:flutter/foundation.dart';
import 'package:cameratricks/displayImage.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';

//List<CameraDescription> cameras;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
      MaterialApp(
        theme: ThemeData.dark(),
        title: 'Flutter Demo',
        home: Camera(cameras: cameras),
      )
  );
}

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  Camera({Key key, @required this.cameras}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  CameraController controller;
  Future<void> _initializeControllerFuture;
  int currentCamera = 0;
  List<String> shuttleImages = [];

  Timer _timer;
  int _start = 3;
  bool isRecording = false;

  void takePic()async{
    try{
      await _initializeControllerFuture;
      final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      await controller.takePicture(path);
//      print('Captured');
      shuttleImages.add(path);
    }catch(e){
      print(e);
    }
  }

  void startTimer(){
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(
          (){
            if (isRecording){
              if (_start == 0){

                _start = 3;
              }else if(_start == 2){
                takePic();
                _start -= 1;
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
  void initState(){
    super.initState();
    controller = new CameraController(
      widget.cameras[currentCamera],
      ResolutionPreset.high,
    );
    _initializeControllerFuture = controller.initialize();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot){
          if (snapshot.connectionState != ConnectionState.done){
            return Center(child: CircularProgressIndicator(),);
          }
          return Container(
            padding: EdgeInsets.only(top: 30),
            color: Colors.black,
            width: _width,
            height: _height,
            child: Stack(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10,),
//                Container(
//                  width: controller.value.aspectRatio * _height,
//                  child: CameraPreview(controller),
//                ),
                Center(
                  child: Transform.scale(
                    scale: controller.value.aspectRatio/ (_width / _height),
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio ,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                if (isRecording)...[
                  Center(
                    child: Text('$_start', style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Times New Roman',
                      fontSize: 116,
                    ),),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.radio_button_checked, color: Colors.red,),
                        SizedBox(width: 10,),
                        Text('Recording', style: TextStyle(color: Colors.redAccent),),
                        SizedBox(width: 50,),
                        Text('${shuttleImages.length}', style: TextStyle(color: Colors.white),),

                      ],
                    ),
                  ),
                ],
                SizedBox(height: 10,),
                Positioned(
                  bottom: 25,
                  left: _width / 2 - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          if (!isRecording){
                            setState(() {
                              isRecording = true;
                              shuttleImages = [];
                            });
                            startTimer();
                          }else{
                            setState(() {
                              isRecording = false;
                              _start = 3;
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => DisplayVideo(list: shuttleImages,)
                              ));
                            });
                          }
//                        try{
//                          await _initializeControllerFuture;
//                          final path = join(
//                            (await getApplicationDocumentsDirectory()).path,
//                            '${DateTime.now()}.png',
//                          );
//                          print(path);
//                          await controller.takePicture(path);
//
//
//                          Navigator.push(context, MaterialPageRoute(
//                            builder: (context) => DisplayPictureScreen(imagePath: path,)
//                          ));
//                        }catch(e){
//                          print(e);
//                        }
                        },
                        child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            padding: (!isRecording)?EdgeInsets.all(5):EdgeInsets.all(6),
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: (isRecording)?
                              Center(
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.red[500],
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                )
                              )
                                :
                              AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                decoration: BoxDecoration(
                                  color: Colors.white70,
                                  border: Border.all(color: Colors.white, width: 2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              )
                        ),
                      ),
                      SizedBox(width: 10,),

                    ],
                  ),
                ),
                Positioned(
                  top: 25,
                  right: 25,
                  child: InkWell(
                    child: Icon(Icons.swap_horiz, size: 30, color: Colors.deepOrange,),
                    onTap: (){
                      setState(() {
                        currentCamera = 1;
                      });
                    },
                  ),
                ),
              ],

            ),
          );
        },
      ),
    );
  }
}

