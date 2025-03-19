import 'package:flutter/material.dart';
import 'package:pd/services/api/build/media/additional_media_controller.dart';
import 'package:pd/services/api/build/media/build_image_caption_controller.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

/// Shows a full-screen image dialog with a PageView for browsing through media,
/// and if the user is the owner, provides options to edit or delete the caption.
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
                                final success = await additionalMediaController
                                    .deleteAdditionalMedia(mediaId: mediaId);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Media deleted successfully.')),
                                  );
                                  await reloadBuildData();
                                  Navigator.of(dialogContext).pop();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Error deleting media.')),
                                  );
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
                          child: Image.network(
                            mediaItem['url']!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Icon(Icons.error,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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

/// Allows the user to edit the caption for a media item.
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
