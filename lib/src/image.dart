import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A bitmap image.
class Image {
  /// Creates a new image with the given dimensions.
  Image(this.width, this.height)
      : _image = img.Image(width: width, height: height);

  /// Creates an image from an Image object.
  Image.fromImage(img.Image image)
      : width = image.width,
        height = image.height,
        _image = image;

  /// Creates an image from raw RGBA pixel data.
  Image.fromRawRgba(this.width, this.height, Uint8List pixels)
      : _image = img.Image.fromBytes(
          width: width,
          height: height,
          bytes: pixels.buffer,
          numChannels: 4,
        );

  /// The width of the image in pixels.
  final int width;

  /// The height of the image in pixels.
  final int height;

  /// The underlying image.
  final img.Image _image;

  /// Returns the underlying image.
  img.Image get image => _image;

  /// Returns the raw RGBA pixel data.
  Uint8List get pixels {
    // Format may have changed in newer versions
    final bytes = _image.getBytes();
    return Uint8List.fromList(bytes);
  }

  /// Returns a copy of this image.
  Image clone() {
    return Image.fromImage(_image.clone());
  }

  /// Disposes of the resources used by this image.
  void dispose() {
    // Currently, the underlying image library doesn't require explicit disposal
    // This method is added for API compatibility and future use
  }

  /// Resizes the image to the given dimensions.
  Image resize(int width, int height) {
    final resized = img.copyResize(_image, width: width, height: height);
    return Image.fromImage(resized);
  }

  /// Encodes this image as a PNG.
  Uint8List toPng() {
    return Uint8List.fromList(img.encodePng(_image));
  }
}
