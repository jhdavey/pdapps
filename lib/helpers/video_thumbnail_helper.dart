import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> generateVideoThumbnail(String videoUrl) async {
  try {
    final Uint8List? bytes = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200, // adjust as needed
      quality: 75,
    );
    return bytes;
  } catch (e) {
    print("Error generating thumbnail: $e");
    return null;
  }
}
