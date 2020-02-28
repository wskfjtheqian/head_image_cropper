使用　基于canvas撸的一个 Vue头像裁剪控件

单指移动，双指移动、缩放、旋转
![输入图片说明](./index.gif?raw=true "在这里输入图片标题")
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
```
dependencies:
  cropperimage:
    git:
      url: https://gitee.com/wskfjt/flutterhead_clipping_control
```


样例：
```
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
```

没有做保持中心旋转的处理，和限制裁剪位置和尺寸的处理

因有自由旋转功能，做保持中心旋转的处理，和限制裁剪位置和尺寸的算法太复杂。没能力处理

如有能力解决者。希望能提供解决方案。

QQ群：1021458098