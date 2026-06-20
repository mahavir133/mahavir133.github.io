import 'dart:io';
import 'package:image/image.dart' as img;

class ImagePreprocessor {
  /// Preprocesses an image file (grayscale, contrast boost, noise filter, thresholding)
  /// and writes the output to a temporary file for OCR.
  static Future<File> preprocess(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return originalFile;

      // 1. Grayscale conversion
      final gray = img.grayscale(image);

      // 2. Contrast enhancement
      final contrast = img.adjustColor(gray, contrast: 1.25);

      // 3. Noise reduction (smooth small fluctuations)
      final blurred = img.gaussianBlur(contrast, radius: 1);

      // 4. Binarization (Luminance thresholding at 55% value)
      final binarized = img.luminanceThreshold(blurred, threshold: 0.55);

      // Save preprocessed image to a temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/ocr_prep_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(img.encodeJpg(binarized));
      return tempFile;
    } catch (_) {
      // Return original file as fallback if preprocessing fails
      return originalFile;
    }
  }
}
