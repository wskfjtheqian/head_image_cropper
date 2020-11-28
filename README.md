使用　基于canvas撸的一个 Flutter头像裁剪控件

* TODO:单指移动，双指移动、缩放、旋转
* TODO:左键移动
* TODO:滚轮旋转
* TODO:左键＋滚轮缩放

![输入图片说明](./index.webp?raw=true "在这里输入图片标题")
输入图片说明

属性 backBoxSize 背景方格大小 默认值：10

backBoxColor0 背景方格颜色0 默认值：Colors.grey

backBoxColor1　　背景方格颜色1 默认值：Colors.white

outWidth 输出图片宽度 默认值：256

outHeight 输出图片高度 默认值：256

maskColor 蒙板颜色 默认值：#00000080

maskPadding 蒙板内边距 默认值：20

lineWidth 预览框线宽 默认值：3

lineColor 预览框颜色 默认值：Colors.white

isArc 是否是圆形 默认值：true

round 预览框圆色 默认值：8

limitations 限制位置和尺寸 默认值：false

image 输入图片源 


方法

outImage() 返回裁剪后的图片


使用
在pubspec.yaml文件中添加
```yaml
dependencies:
  head_image_cropper: ^3.0.0
```


样例：
```dart
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
  var _controller = CropperController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            child: Text("保存"),
            onPressed: () {
              _controller.outImage()?.then((image) async {
                //保存或上传代码
                var bytes =
                    (await (image.toByteData(format: ImageByteFormat.png)))
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

```
