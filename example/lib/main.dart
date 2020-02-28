import 'package:flutter/material.dart';
import 'package:head_image_cropper/cropper_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  var _cropperKey = GlobalKey<CropperImageState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Text("保存"),
              onPressed: () {
                _cropperKey.currentState.outImage().then((image) {
                  //保存或上传代码
                });
              },
            )
          ],
        ),
        body: Container(
          child: CropperImage(
            NetworkImage("http://n.sinaimg.cn/sinacn12/564/w1920h1044/20181111/69c3-hnstwwq4987218.jpg"),
            key: _cropperKey,
          ),
        ),
      ),
    );
  }
}
