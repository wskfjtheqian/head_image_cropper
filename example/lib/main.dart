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
  var _controller = CropperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          TextButton(
            child: Text("保存"),
            style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
            onPressed: () {
              _controller.outImage().then((image) async {
                //保存或上传代码
                var bytes =
                    (await (image.toByteData(format: ImageByteFormat.png)))!
                        .buffer
                        .asUint8List();

                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
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
          AssetImage("images/test.webp"),
          controller: _controller,
        ),
      ),
    );
  }
}

class ShowImage extends StatefulWidget {
  final Uint8List data;

  const ShowImage({Key? key, required this.data}) : super(key: key);

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
