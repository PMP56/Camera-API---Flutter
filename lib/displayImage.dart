import 'package:flutter/material.dart';
import 'dart:io';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Picture')),
      body: Center(child: Image.file(
        File(imagePath),
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.contain,
      )),
    );
  }
}