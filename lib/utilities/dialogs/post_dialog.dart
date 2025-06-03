// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/post_controller.dart';
import 'package:http/http.dart' as http;

class PostDialog extends StatefulWidget {
  final int buildId;
  final Future<void> Function() reloadBuildData;

  const PostDialog({
    Key? key,
    required this.buildId,
    required this.reloadBuildData,
  }) : super(key: key);

  @override
  _PostDialogState createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  File? _selectedMedia;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagInputController = TextEditingController();
  final List<String> _tags = [];

  Future<void> _pickMedia() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile == null) return;
    setState(() => _selectedMedia = File(pickedFile.path));
  }

  void _removeMedia() {
    setState(() => _selectedMedia = null);
  }

  void _addTag() {
    final tagText = _tagInputController.text.trim().toLowerCase();
    if (tagText.isNotEmpty && !_tags.contains(tagText)) {
      setState(() {
        _tags.add(tagText);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(int index) {
    setState(() => _tags.removeAt(index));
  }

  Future<void> _savePost() async {
    if (_selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image or video first.')),
      );
      return;
    }

    final captionText = _captionController.text.trim();

    try {
      final service = PostService();
      final streamedResponse = await service.createPost(
        mediaFile: _selectedMedia!,
        buildId: widget.buildId,
        caption: captionText,
        tags: _tags,
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await widget.reloadBuildData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully.')),
        );
        Navigator.of(context).pop(true);
      } else {
        // Instead of showing the raw HTML dump, send it to console:
        debugPrint(
            '❌ POST /api/build-posts failed → status=${response.statusCode}');
        debugPrint('❌ Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create post. See console for details.'),
          ),
        );
      }
    } catch (e, stack) {
      // Print exception + stack trace to the debug console:
      debugPrint('Error uploading post: $e');
      debugPrint('$stack');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error uploading post. Check console.')),
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Post'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedMedia != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedMedia!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _removeMedia,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Pick Image/Video'),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Post Caption (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagInputController,
                    decoration: const InputDecoration(
                      labelText: 'Add a tag',
                      hintText: 'e.g. track, street',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addTag, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 8),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: List.generate(_tags.length, (index) {
                  final tag = _tags[index];
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(index),
                  );
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _savePost,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
