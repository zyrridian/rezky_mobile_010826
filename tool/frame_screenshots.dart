import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final inputDir = Directory('screenshots');
  final outputDir = Directory('docs/screenshots');

  if (!await inputDir.exists()) {
    print('No screenshots directory found. Run the integration tests first.');
    return;
  }

  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final files = inputDir.listSync().whereType<File>().where((f) => f.path.endsWith('.png'));

  for (final file in files) {
    print('Framing ${file.path}...');
    final screenshot = img.decodePng(file.readAsBytesSync());
    if (screenshot == null) continue;

    // Define device frame dimensions
    final paddingX = 40;
    final paddingY = 80;
    final cornerRadius = 60;
    
    final bgWidth = screenshot.width + (paddingX * 2);
    final bgHeight = screenshot.height + (paddingY * 2);

    // Create a canvas (transparent or light background)
    final canvas = img.Image(width: bgWidth + 100, height: bgHeight + 100);
    img.fill(canvas, color: img.ColorRgba8(240, 240, 240, 255)); // light gray background for the doc

    // Draw device shadow
    img.fillRect(
      canvas,
      x1: 50, y1: 50 + 20, 
      x2: 50 + bgWidth, y2: 50 + bgHeight + 20,
      color: img.ColorRgba8(0, 0, 0, 50),
    );

    // Draw device body (black bezel)
    img.fillRect(
      canvas,
      x1: 50, y1: 50, 
      x2: 50 + bgWidth, y2: 50 + bgHeight,
      color: img.ColorRgba8(20, 20, 20, 255),
    );

    // Draw the actual screenshot
    img.compositeImage(
      canvas,
      screenshot,
      dstX: 50 + paddingX,
      dstY: 50 + paddingY,
    );

    // Draw the notch (simple pill shape at the top)
    final notchWidth = 160;
    final notchHeight = 40;
    final notchX = 50 + (bgWidth ~/ 2) - (notchWidth ~/ 2);
    final notchY = 50 + 20;

    img.fillRect(
      canvas,
      x1: notchX, y1: notchY, 
      x2: notchX + notchWidth, y2: notchY + notchHeight,
      color: img.ColorRgba8(20, 20, 20, 255),
    );

    final filename = file.uri.pathSegments.last;
    final outFile = File('${outputDir.path}/$filename');
    outFile.writeAsBytesSync(img.encodePng(canvas));
    print('Saved framed image to ${outFile.path}');
  }
}
