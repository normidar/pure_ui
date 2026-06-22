part of dart.ui;

Future<void> exportImage({
  required CanvasFunction canvasFunction,
  required Size size,
  required File exportFile,
  ImageByteFormat imageByteFormat = ImageByteFormat.png,
}) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));
  canvasFunction(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size.width.toInt(), size.height.toInt());
  final byteData = await image.toByteData(format: imageByteFormat);
  await exportFile.writeAsBytes(byteData!.buffer.asUint8List());
  image.dispose();
  picture.dispose();
}

typedef CanvasFunction = void Function(Canvas canvas);
