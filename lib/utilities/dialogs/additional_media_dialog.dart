// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/build/media/additional_media_controller.dart';
import 'package:pd/services/api/build/media/build_image_caption_controller.dart';

class _PickedMedia {
  _PickedMedia({
    required this.file,
    this.caption = '',
  });

  final File file;
  String caption;
}

class AdditionalMediaDialog extends StatefulWidget {
  final int buildId;
  final Future<void> Function() reloadBuildData;
  const AdditionalMediaDialog({
    super.key,
    required this.buildId,
    required this.reloadBuildData,
  });

  @override
  _AdditionalMediaDialogState createState() => _AdditionalMediaDialogState();
}

class _AdditionalMediaDialogState extends State<AdditionalMediaDialog> {
  final List<_PickedMedia> _pickedMedia = [];
  final ImagePicker _picker = ImagePicker();

  /// Step 1: let user choose a single image/video from gallery.
  /// Step 2: immediately prompt for a caption (via a simple AlertDialog with a TextField).
  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) return;

    final File file = File(pickedFile.path);
    final String? caption = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String tempCaption = '';
        return AlertDialog(
          title: const Text('Enter Caption (optional)'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Caption...',
            ),
            onChanged: (value) => tempCaption = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(tempCaption),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // If user dismissed “Skip” (returned null), we treat caption as empty string
    final finalCaption = caption ?? '';

    setState(() {
      _pickedMedia.add(_PickedMedia(
        file: file,
        caption: finalCaption,
      ));
    });
  }

  void _removeFile(int index) {
    setState(() {
      _pickedMedia.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    if (_pickedMedia.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }

    try {
      final controller = AdditionalMediaController(
        baseUrl: 'https://passiondrivenbuilds.com',
      );

      final files = _pickedMedia.map((m) => m.file).toList();
      final List<Map<String, dynamic>> createdMedia =
          await controller.uploadAdditionalMedia(
        buildId: widget.buildId,
        files: files,
      );

      final captionController =
          BuildImageCaptionController.buildImageCaptionController(
        baseUrl: 'https://passiondrivenbuilds.com',
      );
      for (int i = 0; i < createdMedia.length && i < _pickedMedia.length; i++) {
        final newMedia = createdMedia[i];
        final int? newMediaId = newMedia['id'] is int
            ? (newMedia['id'] as int)
            : int.tryParse(newMedia['id'].toString());
        final String userCaption = _pickedMedia[i].caption.trim();
        if (newMediaId != null && userCaption.isNotEmpty) {
          await captionController.updateCaption(
            buildImageId: newMediaId,
            caption: userCaption,
          );
        }
      }

      await widget.reloadBuildData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Additional media added successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload additional media.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Additional Media'),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_pickedMedia.isNotEmpty)
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pickedMedia.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final pm = _pickedMedia[index];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              pm.file,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, st) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (pm.caption.isNotEmpty)
                            Positioned(
                              bottom: -2,
                              left: 0,
                              right: 0,
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  pm.caption.length > 20
                                      ? '${pm.caption.substring(0, 20)}…'
                                      : pm.caption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                )
              else
                const Text('No media selected.'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.add),
                label: const Text('Add Media'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _uploadFiles,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
