// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pd/services/api/build/media/additional_media_controller.dart';
import 'package:pd/services/api/build/media/build_image_caption_controller.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';
import 'package:pd/utilities/dialogs/additional_media_dialog.dart';
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

  // Convert rawMedia into a list of maps.
  final List<Map<String, dynamic>> mediaList = rawMedia is List
      ? rawMedia
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
          .toList()
      : [];

  // Reverse the media order so that the most recent added media shows up first.
  final List<Map<String, dynamic>> reversedMediaList =
      mediaList.reversed.toList();

  return Builder(
    builder: (BuildContext outerContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isOwner)
                  IconButton(
                    icon:
                        const Icon(Icons.add, color: Colors.white, size: 30),
                    onPressed: () async {
                      final bool? result = await showDialog<bool>(
                        context: outerContext,
                        builder: (BuildContext dialogContext) {
                          return AdditionalMediaDialog(
                            buildId: int.parse(build['id'].toString()),
                            reloadBuildData: reloadBuildData,
                          );
                        },
                      );
                      if (result == true) {
                        ScaffoldMessenger.of(outerContext).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Additional media added successfully.'),
                          ),
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
          reversedMediaList.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "No additional media added yet...",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              : SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: reversedMediaList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final media = reversedMediaList[index];
                      Widget mediaWidget;
                      if (media['type'] == 'video') {
                        mediaWidget = GestureDetector(
                          onTap: () => showVideoDialog(context, media['url']),
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF1F242C),
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
                            reversedMediaList,
                            index,
                            isOwner: isOwner,
                            reloadBuildData: reloadBuildData,
                          ),
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
                          // Caption overlay (if exists)
                          if ((media['caption'] as String).isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                color: Colors.black.withOpacity(0.8),
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                ),
        ],
      );
    },
  );
}

/// Updated showImageDialog with owner controls and caption below the image.
void showImageDialog(
  BuildContext context,
  List<Map<String, dynamic>> media,
  int initialIndex, {
  bool isOwner = false,
  required Future<void> Function() reloadBuildData,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      int currentIndex = initialIndex;
      final PageController controller =
          PageController(initialPage: initialIndex);
      return Dialog(
        backgroundColor: const Color(0xFF1F242C),
        insetPadding: const EdgeInsets.all(16),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top row with close button and, if owner, edit & delete icons.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isOwner) ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            editCaption(
                              context,
                              currentIndex,
                              media,
                              reloadBuildData,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final bool confirm =
                                await showDeleteDialog(context, 'media');
                            if (confirm) {
                              final mediaId = media[currentIndex]['id'];
                              if (mediaId != null) {
                                final additionalMediaController =
                                    AdditionalMediaController(
                                        baseUrl:
                                            'https://passiondrivenbuilds.com');
                                final success =
                                    await additionalMediaController
                                        .deleteAdditionalMedia(
                                            mediaId: mediaId);
                                if (success) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Media deleted successfully.')));
                                  await reloadBuildData();
                                  Navigator.of(dialogContext).pop();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                          content:
                                              Text('Error deleting media.')));
                                }
                              }
                            }
                          },
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                  // The media PageView.
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemCount: media.length,
                      itemBuilder: (BuildContext context, int index) {
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
                  // Spacer between the image and the caption.
                  const SizedBox(height: 8),
                  // Display caption below the expanded image.
                  if ((media[currentIndex]['caption'] ?? '')
                      .toString()
                      .isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFF1F242C),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
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

void editCaption(
  BuildContext context,
  int index,
  List<Map<String, dynamic>> mediaList,
  Future<void> Function() reloadBuildData,
) {
  final currentCaption = mediaList[index]['caption'] as String;
  final TextEditingController controller =
      TextEditingController(text: currentCaption);
  showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
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
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),
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
                    Navigator.of(dialogContext).pop(true);
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
                Navigator.of(dialogContext).pop(true);
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
    if (result == true) {}
  });
}

void showVideoDialog(BuildContext context, String videoUrl) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: const Color(0xFF1F242C),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayerWidget(videoUrl: videoUrl),
        ),
      );
    },
  );
}
