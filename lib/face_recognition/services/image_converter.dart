import 'dart:typed_data';

import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';

imglib.Image _convertYUV420(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final imglib.Image img = imglib.Image(width: width, height: height);
  final int ySize = width * height;
  final int uvSize = ySize ~/ 4;

  // Extract Y, U, and V planes
  final Uint8List yPlane = image.planes[0].bytes;
  final Uint8List uPlane = image.planes[1].bytes;
  final Uint8List vPlane = image.planes[2].bytes;

  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  // Loop through each pixel
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * width + x;
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final int yp = yPlane[yIndex];
      final int up = uPlane[uvIndex];
      final int vp = vPlane[uvIndex];

      // Convert YUV to RGB
      final int r = (yp + (1.402 * (vp - 128))).toInt().clamp(0, 255);
      final int g = (yp - (0.344136 * (up - 128)) - (0.714136 * (vp - 128)))
          .toInt()
          .clamp(0, 255);
      final int b = (yp + (1.772 * (up - 128))).toInt().clamp(0, 255);

      // Set pixel color
      // img.setPixel(x, y, imglib.getColor(r, g, b)); // ARGB
    }
  }

  return img;
}
