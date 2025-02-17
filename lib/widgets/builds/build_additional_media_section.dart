// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/build_image_caption_controller.dart';
import 'package:pd/widgets/video_player.dart';

Widget buildAdditionalMediaSection(
  Map<String, dynamic> build, {
  required Future<void> Function() reloadBuildData,
  required bool isOwner,
}) {
  final dynamic rawMedia = build['additional_media'] ??
      (build['additional_images'] is String
          ? jsonDecode(build['additional_images'])
          : build['additional_images']);

  if (rawMedia is! List || rawMedia.isEmpty) return const SizedBox.shrink();

  // Convert rawMedia into a list of maps.
  final List<Map<String, dynamic>> mediaList = rawMedia
      .map<Map<String, dynamic>>((item) {
        if (item is String) {
          return {
            'id': null,
            'url': item,
            'type': 'image',
            'caption': '',
          };
        } else if (item is Map) {
          final mapItem = Map<String, dynamic>.from(item);
          mapItem.putIfAbsent('type', () => 'image');
          mapItem.putIfAbsent('caption', () => '');
          mapItem.putIfAbsent('id', () => null);
          return mapItem;
        } else {
          return {};
        }
      })
      .where((element) => element.isNotEmpty)
      .toList();

  // Build a horizontally scrolling list of media items.
  return SizedBox(
    height: 200,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: mediaList.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final media = mediaList[index];

        Widget mediaWidget;
        if (media['type'] == 'video') {
          mediaWidget = GestureDetector(
            onTap: () => showVideoDialog(context, media['url']),
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black,
              ),
              child: const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          );
        } else {
          mediaWidget = GestureDetector(
            onTap: () => showImageDialog(
                context,
                mediaList.map((m) {
                  return {
                    'url': m['url'].toString(),
                    'type': m['type'].toString(),
                    'caption': m['caption']?.toString() ?? '',
                  };
                }).toList(),
                index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                media['url'],
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            ),
          );
        }

        return Stack(
          children: [
            mediaWidget,
            // Show the edit button if the user is the owner.
            if (isOwner)
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () =>
                      editCaption(context, index, mediaList, reloadBuildData),
                ),
              ),
            // If a caption exists, overlay a semi-transparent caption box.
            if ((media['caption'] as String).isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  color: Colors.black.withOpacity(0.8),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    (media['caption'] as String).length > 30
                        ? "${(media['caption'] as String).substring(0, 30)}..."
                        : media['caption'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

// Separate helper for editing captions.
void editCaption(
    BuildContext context,
    int index,
    List<Map<String, dynamic>> mediaList,
    Future<void> Function() reloadBuildData) {
  final currentCaption = mediaList[index]['caption'] as String;
  final TextEditingController controller =
      TextEditingController(text: currentCaption);
  showDialog<bool>(
    context: context,
    builder: (context) {
      String newCaption = currentCaption;
      return AlertDialog(
        title: const Text("Edit Caption"),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Caption",
            hintText: "Enter a caption",
          ),
          controller: controller,
          onChanged: (value) {
            newCaption = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          // Delete button (if caption exists).
          if (currentCaption.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final bool confirm = await showDeleteDialog(context, 'caption');
                if (confirm) {
                  final buildImageId = mediaList[index]['id'];
                  bool success = true;
                  if (buildImageId != null) {
                    final buildImageController =
                        BuildImageCaptionController.buildImageCaptionController(
                      baseUrl: 'https://passiondrivenbuilds.com',
                    );
                    success = await buildImageController.updateCaption(
                      buildImageId: buildImageId,
                      caption: '',
                    );
                  }
                  if (success) {
                    mediaList[index]['caption'] = '';
                    Navigator.of(context).pop(true);
                    await reloadBuildData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error deleting caption')),
                    );
                  }
                }
              },
            ),
          ElevatedButton(
            onPressed: () async {
              final buildImageId = mediaList[index]['id'];
              bool success = true;
              if (buildImageId != null) {
                final buildImageController =
                    BuildImageCaptionController.buildImageCaptionController(
                  baseUrl: 'https://passiondrivenbuilds.com',
                );
                success = await buildImageController.updateCaption(
                  buildImageId: buildImageId,
                  caption: newCaption,
                );
              }
              if (success) {
                mediaList[index]['caption'] = newCaption;
                Navigator.of(context).pop(true);
                await reloadBuildData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error updating caption')),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  ).then((result) async {
    if (result == true) {
      // Additional actions if needed.
    }
  });
}

// Generic delete dialog.
Future<bool> showDeleteDialog(BuildContext context, String itemType) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Are you sure you want to delete this $itemType?'),
      actions: {
        'Cancel': () => Navigator.of(context).pop(false),
        'Yes': () => Navigator.of(context).pop(true),
      }.entries.map((entry) {
        return TextButton(
          onPressed: entry.value,
          child: Text(entry.key),
        );
      }).toList(),
    ),
  ).then((value) => value ?? false);
}

void showImageDialog(
  BuildContext context,
  List<Map<String, String>> media,
  int initialIndex,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      // Declare currentIndex outside the StatefulBuilder's builder so it persists.
      int currentIndex = initialIndex;
      final PageController controller =
          PageController(initialPage: initialIndex);
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row 1: Close button at the far right.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  // Row 2: PageView to scroll horizontally through media items.
                  Container(
                    height: 300, // Adjust height as needed.
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemCount: media.length,
                      itemBuilder: (context, index) {
                        final mediaItem = media[index];
                        return Hero(
                          tag: mediaItem['url']!,
                          child: mediaItem['type'] == 'image'
                              ? Image.network(
                                  mediaItem['url']!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Icon(Icons.error,
                                        size: 50, color: Colors.white),
                                  ),
                                )
                              : AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: VideoPlayerWidget(
                                      videoUrl: mediaItem['url']!),
                                ),
                        );
                      },
                    ),
                  ),
                  // Row 3: Caption directly below the media.
                  if ((media[currentIndex]['caption'] ?? '')
                      .toString()
                      .isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight:
                              200, // Allow vertical scrolling if caption is long.
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            media[currentIndex]['caption']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
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
