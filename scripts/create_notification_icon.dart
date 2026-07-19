import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = 'assets/images/app_icon.png';
  final file = File(inputPath);
  if (!file.existsSync()) {
    print('File not found: $inputPath');
    return;
  }

  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) {
    print('Failed to decode image');
    return;
  }

  // Create a new image with the same dimensions
  final silhouette = img.Image(width: image.width, height: image.height, numChannels: 4);

  // Convert to a white silhouette based on alpha channel
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      
      // Get alpha channel (0-255)
      // In package:image v4, pixel.a is a num, we can use it.
      final alpha = pixel.a;
      
      if (alpha > 0) {
        // If not fully transparent, make it solid white with the original alpha
        silhouette.setPixelRgba(x, y, 255, 255, 255, alpha);
      } else {
        silhouette.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  // Resize it to 96x96 which is appropriate for xxhdpi notification icons
  final resized = img.copyResize(silhouette, width: 96, height: 96);

  // Save to drawable
  final outDir = Directory('android/app/src/main/res/drawable');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }
  
  final outPath = '${outDir.path}/ic_notification.png';
  File(outPath).writeAsBytesSync(img.encodePng(resized));
  print('Saved notification icon to $outPath');
}
