// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/build/media/additional_media_controller.dart';

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
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFiles.add(File(pickedFile.path));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      Navigator.of(context).pop(false);
      return;
    }
    try {
      // Create an instance of AdditionalMediaController with your base URL.
      final controller =
          AdditionalMediaController(baseUrl: 'https://passiondrivenbuilds.com');
      await controller.uploadAdditionalMedia(
          buildId: widget.buildId, files: _selectedFiles);
      // After a successful upload, reload the build data and show a success message.
      await widget.reloadBuildData();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Additional media added successfully.')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload additional media.')));
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
              _selectedFiles.isNotEmpty
                  ? SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedFiles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Image.file(
                                _selectedFiles[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
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
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : const Text('No media selected.'),
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
