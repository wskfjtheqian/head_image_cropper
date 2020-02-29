library head_image_cropper;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:ui' as sky show Image;

class CropperImage extends StatefulWidget {
  static const Color defualtMaskColor = Color.fromARGB(160, 0, 0, 0);

  CropperImage(
    this.image, {
    Key key,
    this.limitations = true,
    this.isArc = false,
    this.backBoxSize = 10.0,
    this.backBoxColor0 = Colors.grey,
    this.backBoxColor1 = Colors.white,
    this.maskColor = defualtMaskColor,
    this.lineColor = Colors.white,
    this.lineWidth = 3,
    this.outWidth = 256.0,
    this.outHeight = 256.0,
    this.maskPadding = 20.0,
    this.round = 8.0,
  }) : super(key: key);

  ImageProvider image;
  bool limitations;
  bool isArc;
  double backBoxSize;
  Color backBoxColor0;
  Color backBoxColor1;
  Color maskColor;
  Color lineColor;
  double lineWidth;
  double outWidth;
  double outHeight;
  double maskPadding;
  double round;

  @override
  CropperImageState createState() => CropperImageState();
}

class CropperImageState extends State<CropperImage> {
  _Param _param = _Param();
  Size _size = Size.zero;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  bool _isListeningToStream = false;
  double _scale;
  double _rotation;
  double _dx;
  double _dy;

  ImageStreamListener _imageStreamListener;

  @override
  void didChangeDependencies() {
    _resolveImage();

    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CropperImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) _resolveImage();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  void _resolveImage() {
    final ImageStream newStream = widget.image.resolve(createLocalImageConfiguration(
      context,
    ));
    assert(newStream != null);
    _updateSourceStream(newStream);
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _param = _Param(
        limitations: widget.limitations,
        isArc: widget.isArc,
        backBoxColor0: widget.backBoxColor0,
        backBoxColor1: widget.backBoxColor1,
        backBoxSize: widget.backBoxSize,
        maskColor: widget.maskColor,
        lineColor: widget.lineColor,
        lineWidth: widget.lineWidth,
        outWidth: widget.outWidth,
        outHeight: widget.outHeight,
        maskPadding: widget.maskPadding,
        round: widget.round,
      );
      _imageInfo = imageInfo;
    });
  }

  // Update _imageStream to newStream, and moves the stream listener
  // registration from the old stream to the new stream (if a listener was
  // registered).
  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream) _imageStream.removeListener(_imageStreamListener);

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream.addListener(_imageStreamListener);
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream.addListener(_imageStreamListener);
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream.removeListener(_imageStreamListener);
    _isListeningToStream = false;
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    super.dispose();
  }

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
          _param.scale *= (details.scale / _scale);
          _scale = details.scale;

          _param.rotate += (details.rotation - _rotation);
          _rotation = details.rotation;

          _param.drawX += details.focalPoint.dx - _dx;
          _dx = details.focalPoint.dx;

          _param.drawY += details.focalPoint.dy - _dy;
          _dy = details.focalPoint.dy;
          print(details.toString());
        });
      },
      child: CustomPaint(
        size: _size,
        painter: _CropperImagePainter(_imageInfo, _param),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      setState(() {
        _size = MediaQuery.of(context).size;
      });
    });

    _imageStreamListener = ImageStreamListener(_handleImageChanged);
  }

  Future<sky.Image> outImage() {
    var recorder = PictureRecorder();
    var canvas = Canvas(recorder, Rect.fromLTRB(0, 0, _param.outWidth, _param.outHeight));

    if (null != _imageInfo) {
      var scale = widget.outHeight / (_param.bottom - _param.top);
      canvas.translate(_param.outWidth / 2 + _param.drawX * scale, _param.outHeight / 2 + _param.drawY * scale);

      canvas.rotate(_param.rotate);
      canvas.scale(_param.scale * scale);
      canvas.drawImage(
          _imageInfo.image,
          Offset(
            -_imageInfo.image.width / 2,
            -_imageInfo.image.height / 2,
          ),
          Paint());
    }

    return recorder.endRecording().toImage(_param.outWidth.toInt(), _param.outHeight.toInt());
  }
}

class _Param {
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

  _Param(
      {this.limitations,
      this.isArc,
      this.backBoxSize,
      this.backBoxColor0,
      this.backBoxColor1,
      this.maskColor,
      this.lineColor,
      this.lineWidth,
      this.outWidth,
      this.outHeight,
      this.maskPadding,
      this.round});

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
}

class _CropperImagePainter extends CustomPainter {
  ImageInfo image = null;
  _Param _param;

  _CropperImagePainter(this.image, this._param);

  @override
  void paint(Canvas canvas, Size size) {
    if (size == Size.zero) {
      return;
    }

    canvas.drawColor(Colors.blue, BlendMode.clear);
    _onPadding(size);
    _createBack(canvas, size);
    if (null != image) {
      _onPosition();
      canvas.save();
      canvas.translate(_param.centerX + _param.drawX, _param.centerY + _param.drawY);
      canvas.rotate(_param.rotate);
      canvas.scale(_param.scale);
      canvas.drawImage(
          image.image,
          Offset(
            -image.image.width / 2,
            -image.image.height / 2,
          ),
          Paint());
      canvas.restore();
    }

    _craeteMask(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  _createBack(Canvas canvas, Size size) {
    for (double y = 0; y < size.height; y += _param.backBoxSize) {
      var color = (0 == (y / _param.backBoxSize) % 2) ? _param.backBoxColor0 : _param.backBoxColor1;

      for (double x = 0; x < size.width; x += _param.backBoxSize) {
        canvas.drawRect(Rect.fromLTRB(x, y, x + _param.backBoxSize, y + _param.backBoxSize),
            Paint()..color = (color = color == _param.backBoxColor1 ? _param.backBoxColor0 : _param.backBoxColor1));
      }
    }
  }

  _craeteMask(Canvas canvas, Size size) {
    if (_param.isArc) {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addOval(Rect.fromLTWH(_param.left, _param.top, _param.right, _param.bottom))
            ..close(),
          Paint()
            ..color = _param.maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addOval(Rect.fromLTWH(_param.left, _param.top, _param.right, _param.bottom))
            ..close(),
          Paint()
            ..color = _param.lineColor
            ..strokeWidth = _param.lineWidth
            ..style = PaintingStyle.stroke);
    } else {
      canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(0, size.height)
            ..lineTo(size.width, size.height)
            ..lineTo(size.width, 0)
            ..addRRect(RRect.fromLTRBXY(_param.left, _param.top, _param.right, _param.bottom, _param.round, _param.round))
            ..close(),
          Paint()
            ..color = _param.maskColor
            ..style = PaintingStyle.fill);

      canvas.drawPath(
          Path()
            ..addRRect(RRect.fromLTRBXY(_param.left, _param.top, _param.right, _param.bottom, _param.round, _param.round))
            ..close(),
          Paint()
            ..color = _param.lineColor
            ..strokeWidth = _param.lineWidth
            ..style = PaintingStyle.stroke);
    }
  }

  _onPadding(Size size) {
    var fw = size.width / _param.outWidth;
    var fh = size.height / _param.outHeight;
    if (fw > fh) {
      fw = fh;
    }
    var width = _param.outWidth * fw / 2 - _param.maskPadding;
    var height = _param.outHeight * fw / 2 - _param.maskPadding;
    _param.centerX = size.width / 2;
    _param.centerY = size.height / 2;
    _param.left = _param.centerX - width;
    _param.right = _param.centerX + width;
    _param.top = _param.centerY - height;
    _param.bottom = _param.centerY + height;
  }

  _onPosition() {
    if (5 < _param.scale) {
      _param.scale = 5;
    }

    var fw = (_param.right - _param.left) / image.image.width;
    var fh = (_param.bottom - _param.top) / image.image.height;
    if (fw < fh) {
      fw = fh;
    }
    if (_param.scale < fw) {
      _param.scale = fw;
    }
    //  TODO 限制
    // drawX
    // drawY
    // rotate
  }
}
