import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:head_image_cropper/head_image_cropper.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _cropperKey = GlobalKey();

  ImageProvider _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text("保存"),
            onPressed: () {
              (_cropperKey.currentContext as CropperImageElement).outImage().then((image) async {
                //保存或上传代码
                var bytes = (await (image.toByteData(format: ImageByteFormat.png))).buffer.asUint8List();

                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return ShowImage(
                    data: bytes,
                  );
                }));
//                  File("path").writeAsBytesSync(bytes);
              });
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(50),
        child: CropperImage(
          NetworkImage("http://n.sinaimg.cn/sinacn12/564/w1920h1044/20181111/69c3-hnstwwq4987218.jpg"),
          key: _cropperKey,
        ),
      ),
    );
  }
}

class ShowImage extends StatefulWidget {
  final Uint8List data;

  const ShowImage({Key key, this.data}) : super(key: key);

  @override
  _ShowImageState createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("裁剪效果"),
      ),
      body: Image.memory(widget.data),
    );
  }
}
