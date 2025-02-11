import 'package:flutter/material.dart';
import 'package:pd/widgets/video_player.dart';

Widget buildAdditionalMediaSection(Map<String, dynamic> build) {
  final dynamic rawMedia = build['additional_media'] ?? build['additional_images'];

  if (rawMedia is List && rawMedia.isNotEmpty) {
    final List<Map<String, dynamic>> mediaList = rawMedia.map<Map<String, dynamic>>((item) {
      if (item is String) {
        return {'url': item, 'type': 'image'};
      } else if (item is Map) {
        final mapItem = Map<String, dynamic>.from(item);
        if (!mapItem.containsKey('type')) {
          mapItem['type'] = 'image';
        }
        return mapItem;
      } else {
        return {};
      }
    }).where((element) => element.isNotEmpty).toList();

    if (mediaList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ClipRect(
          child: SizedBox(
            width: double.infinity,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: mediaList.length,
              itemBuilder: (context, index) {
                final media = mediaList[index];

                if (media['type'] == 'video') {
                  return GestureDetector(
                    onTap: () => showVideoDialog(context, media['url']),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black,
                          ),
                        ),
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 50),
                      ],
                    ),
                  );
                } else {
                  // Convert mediaList into List<Map<String, String>> before passing it to the dialog.
                  final convertedMediaList = mediaList.map<Map<String, String>>((m) {
                    return {
                      'url': m['url'].toString(),
                      'type': m['type'].toString(),
                    };
                  }).toList();

                  return GestureDetector(
                    onTap: () => showImageDialog(context, convertedMediaList, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        media['url'],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  } else {
    return const SizedBox.shrink();
  }
}

void showImageDialog(BuildContext context, List<Map<String, String>> media, int initialIndex) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: media.length,
              itemBuilder: (context, index) {
                final mediaItem = media[index];

                return Center(
                  child: Hero(
                    tag: mediaItem['url']!,
                    child: GestureDetector(
                      onTap: () {},
                      child: mediaItem['type'] == 'image'
                          ? Image.network(
                              mediaItem['url']!,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white)));
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(Icons.error, size: 50, color: Colors.white),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: 16 / 9,
                              child: VideoPlayerWidget(videoUrl: mediaItem['url']!),
                            ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 20,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showVideoDialog(BuildContext context, String videoUrl) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(videoUrl: videoUrl),
        ),
      );
    },
  );
}
