library head_image_cropper;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:ui' as ui show Image;

const Color _defualtMaskColor = Color.fromARGB(160, 0, 0, 0);

class CropperImage extends StatefulWidget {
  final ImageProvider image;
  final bool limitations;
  final bool isArc;
  final double backBoxSize;
  final Color backBoxColor0;
  final Color backBoxColor1;
  final Color maskColor;
  final Color lineColor;
  final double lineWidth;
  final double outWidth;
  final double outHeight;
  final double maskPadding;
  final double round;

  CropperImage(
      this.image, {
        Key key,
        this.limitations = true,
        this.isArc = false,
        this.backBoxSize = 10.0,
        this.backBoxColor0 = Colors.grey,
        this.backBoxColor1 = Colors.white,
        this.maskColor = _defualtMaskColor,
        this.lineColor = Colors.white,
        this.lineWidth = 3,
        this.outWidth = 256.0,
        this.outHeight = 256.0,
        this.maskPadding = 20.0,
        this.round = 8.0,
      }) : super(key: key);

  @override
  CropperImageState createState() => CropperImageState();
}

class CropperImageState extends State<CropperImage> {
  _CropperImagePainter _painter = _CropperImagePainter();

  Size _size = Size.zero;
  double _scale;
  double _rotation;
  double _dx;
  double _dy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        _scale = 1;
        _rotation = 0;
        _dx = details.focalPoint.dx;
        _dy = details.focalPoint.dy;
      },
      onScaleUpdate: (details) {
        setState(() {
          _painter.scale *= (details.scale / _scale);
          _scale = details.scale;

          _painter.rotate += (details.rotation - _rotation);
          _rotation = details.rotation;

          _painter.drawX += details.focalPoint.dx - _dx;
          _dx = details.focalPoint.dx;

          _painter.drawY += details.focalPoint.dy - _dy;
          _dy = details.focalPoint.dy;
          print(details.toString());
        });
        context.findRenderObject().markNeedsPaint();
      },
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          size: constraints.biggest,
          painter: _painter,
        );
      }),
    );
  }

  Future<ui.Image> outImage() {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder, Rect.fromLTRB(0, 0, widget.outWidth, widget.outHeight));

    if (null != _painter.image) {
      var scale = widget.outHeight / (_painter.bottom - _painter.top);
      canvas.translate(_painter.outWidth / 2 + _painter.drawX * scale, _painter.outHeight / 2 + _painter.drawY * scale);

      canvas.rotate(_painter.rotate);
      canvas.scale(_painter.scale * scale);
      canvas.drawImage(_painter.image, Offset(-_painter.image.width / 2, -_painter.image.height / 2), Paint());
    }

    return recorder.endRecording().toImage(widget.outWidth.toInt(), widget.outHeight.toInt());
  }

  @override
  void initState() {
    super.initState();
    _updateParam();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }
  @override
  void didUpdateWidget(CropperImage oldWidget) {
    if (widget.image != oldWidget.image) {
      _resolveImage();
    }
    _updateParam();
    super.didUpdateWidget(oldWidget);
  }

  void _updateParam() {
    _painter
      ..limitations = widget.limitations
      ..isArc = widget.isArc
      ..backBoxColor0 = widget.backBoxColor0
      ..backBoxColor1 = widget.backBoxColor1
      ..backBoxSize = widget.backBoxSize
      ..maskColor = widget.maskColor
      ..lineColor = widget.lineColor
      ..lineWidth = widget.lineWidth
      ..outWidth = widget.outWidth
      ..outHeight = widget.outHeight
      ..maskPadding = widget.maskPadding
      ..round = widget.round;
  }

  void _resolveImage() {
    if (null == widget.image) {
      return;
    }
    final ImageStream stream = widget.image.resolve(createLocalImageConfiguration(context));
    var listener;
    listener = ImageStreamListener((image, synchronousCall) {
      _painter.image = image.image;
      context.findRenderObject().markNeedsPaint();
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }
}

class _CropperImagePainter extends CustomPainter {
  ui.Image image = null;
  bool limitations = true;
  bool isArc = false;
  double backBoxSize = 10.0;
  Color backBoxColor0 = Colors.grey;
  Color backBoxColor1 = Colors.white;
  Color maskColor = Color.fromARGB(80, 0, 0, 0);
  Color lineColor = Colors.white;
  double lineWidth = 3;
  double outWidth = 256.0;
  double outHeight = 256.0;
  double maskPadding = 20.0;
  double round = 8.0;

  double scale = 0;
  double centerX;
  double centerY;
  double drawX = 0;
  double drawY = 0;
  double bottom;
  double left;
  double right;
  double top;
  double rotate = 0;

  _CropperImagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size == Size.zero) {
      return;
    }
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawColor(Colors.blue, BlendMode.clear);
    _onPadding(size);
    _createBack(canvas, size);
    if (null != image) {
      _onPosition();
      canvas.save();
      canvas.translate(centerX + drawX, centerY + drawY);
      canvas.rotate(rotate);
      canvas.scale(scale);
      canvas.drawImage(image, Offset(-image.width / 2, -image.height / 2), Paint());
      canvas.restore();
    }

    _craeteMask(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  _createBack(Canvas canvas, Size size) {
    for (double y = 0; y < size.height; y += backBoxSize) {
      var color = (0 == (y / backBoxSize) % 2) ? backBoxColor0 : backBoxColor1;

      for (double x = 0; x < size.width; x += backBoxSize) {
        canvas.drawRect(
            Rect.fromLTRB(x, y, x + backBoxSize, y + backBoxSize), Paint()..color = (color = color == backBoxColor1 ? backBoxColor0 : backBoxColor1));
      }
    }
  }

  _craeteMask(Canvas canvas, Size size) {
    if (isArc) {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addOval(Rect.fromLTWH(left, top, right, bottom))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addOval(Rect.fromLTWH(left, top, right, bottom))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    } else {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addRRect(RRect.fromLTRBXY(left, top, right, bottom, round, round))
            ..close(),
          Paint()
            ..color = maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBXY(left, top, right, bottom, round, round))
            ..close(),
          Paint()
            ..color = lineColor
            ..strokeWidth = lineWidth
            ..style = PaintingStyle.stroke);
    }
  }

  _onPadding(Size size) {
    var fw = size.width / outWidth;
    var fh = size.height / outHeight;
    if (fw > fh) {
      fw = fh;
    }
    var width = outWidth * fw / 2 - maskPadding;
    var height = outHeight * fw / 2 - maskPadding;
    centerX = size.width / 2;
    centerY = size.height / 2;
    left = centerX - width;
    right = centerX + width;
    top = centerY - height;
    bottom = centerY + height;
  }

  _onPosition() {
    if (5 < scale) {
      scale = 5;
    }

    var fw = (right - left) / image.width;
    var fh = (bottom - top) / image.height;
    if (fw < fh) {
      fw = fh;
    }
    if (scale < fw) {
      scale = fw;
    }
    //  TODO 限制
    // drawX
    // drawY
    // rotate
  }
}
