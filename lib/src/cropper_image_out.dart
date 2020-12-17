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
  var recorder = ui.PictureRecorder();
  var canvas = ui.Canvas(recorder, ui.Rect.fromLTRB(0, 0, outWidth, outHeight));

  if (null != image) {
    var temp = outHeight / (bottom - top);

    canvas.translate(outWidth / 2 + drawX * temp, outHeight / 2 + drawY * temp);
    canvas.rotate(rotate1);
    canvas.scale(scale * temp);
    canvas.drawImage(
        image, ui.Offset(-image.width / 2, -image.height / 2), ui.Paint());
  }
  ui.Picture picture = recorder.endRecording();
  return picture.toImage(outWidth.toInt(), outHeight.toInt());
}
