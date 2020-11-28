import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'dart:ui' as ui;

Future<ui.Image> outImage({
  ui.Image image,
  double outWidth,
  double outHeight,
  double bottom,
  double top,
  double drawX,
  double drawY,
  double rotate1,
  double scale,
}) {
  var canvas =
      CanvasElement(width: outWidth.toInt(), height: outHeight.toInt());
  if (null != image) {
    var temp = outHeight / (bottom - top);

    canvas.context2D
        .translate(outWidth / 2 + drawX * temp, outHeight / 2 + drawY * temp);
    canvas.context2D.rotate(rotate1);
    canvas.context2D.scale(scale * temp, scale * temp);
    canvas.context2D.drawImage(
        (image as dynamic).imgElement, -image.width / 2, -image.height / 2);
  }

  return Future.value((HtmlImage(canvas)));
}

class HtmlImage implements ui.Image {
  CanvasElement element;

  HtmlImage(this.element);

  @override
  void dispose() {}

  @override
  int get height => element.height;

  @override
  Future<ByteData> toByteData(
      {ui.ImageByteFormat format = ui.ImageByteFormat.png}) async {
    var completer = new Completer<ByteData>();

    final out = new FileReader();
    out.onLoadEnd.listen((event) {
      completer.complete((out.result as Uint8List).buffer.asByteData());
    });
    out.onError.listen((event) {
      completer.completeError(event);
    });
    out.readAsArrayBuffer(await element.toBlob());
    return completer.future;
  }

  int get width => element.width;

  @override
  ui.Image clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }

  @override
  bool get debugDisposed => throw UnimplementedError();

  @override
  List<StackTrace> debugGetOpenHandleStackTraces() {
    // TODO: implement debugGetOpenHandleStackTraces
    throw UnimplementedError();
  }

  @override
  bool isCloneOf(ui.Image other) {
    return false;
  }
}
