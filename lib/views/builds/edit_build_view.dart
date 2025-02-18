// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/data/build_categories.dart';
import 'package:pd/helpers/image_picker.dart';
import 'package:pd/services/api/build/delete_build.dart';
import 'package:pd/services/api/build/edit_build.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class AdditionalMedia {
  final File file;
  final String type;
  final String extension;

  AdditionalMedia({
    required this.file,
    required this.type,
    required this.extension,
  });
}

class EditBuildView extends StatefulWidget {
  final Map<String, dynamic> build;

  const EditBuildView({super.key, required this.build});

  @override
  _EditBuildViewState createState() => _EditBuildViewState();
}

class _EditBuildViewState extends State<EditBuildView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _trimController = TextEditingController();
  final TextEditingController _hpController = TextEditingController();
  final TextEditingController _whpController = TextEditingController();
  final TextEditingController _torqueController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _vehicleLayoutController =
      TextEditingController();
  final TextEditingController _fuelController = TextEditingController();
  final TextEditingController _zeroSixtyController = TextEditingController();
  final TextEditingController _zeroOneHundredController =
      TextEditingController();
  final TextEditingController _quarterMileController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _engineCodeController = TextEditingController();
  final TextEditingController _forcedInductionController =
      TextEditingController();
  final TextEditingController _transController = TextEditingController();
  final TextEditingController _suspensionController = TextEditingController();
  final TextEditingController _brakesController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;

  List<Map<String, dynamic>> _existingAdditionalMedia = [];
  List<String> removedAdditionalMedia = [];
  List<AdditionalMedia> newAdditionalMedia = [];

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    _yearController.text = widget.build['year']?.toString() ?? '';
    _makeController.text = widget.build['make']?.toString() ?? '';
    _modelController.text = widget.build['model']?.toString() ?? '';
    _trimController.text = widget.build['trim']?.toString() ?? '';
    _hpController.text = widget.build['hp']?.toString() ?? '';
    _whpController.text = widget.build['whp']?.toString() ?? '';
    _torqueController.text = widget.build['torque']?.toString() ?? '';
    _weightController.text = widget.build['weight']?.toString() ?? '';
    _vehicleLayoutController.text =
        widget.build['vehicleLayout']?.toString() ?? '';
    _fuelController.text = widget.build['fuel']?.toString() ?? '';
    _zeroSixtyController.text = widget.build['zeroSixty']?.toString() ?? '';
    _zeroOneHundredController.text =
        widget.build['zeroOneHundred']?.toString() ?? '';
    _quarterMileController.text = widget.build['quarterMile']?.toString() ?? '';
    _engineTypeController.text = widget.build['engineType']?.toString() ?? '';
    _engineCodeController.text = widget.build['engineCode']?.toString() ?? '';
    _forcedInductionController.text =
        widget.build['forcedInduction']?.toString() ?? '';
    _transController.text = widget.build['trans']?.toString() ?? '';
    _suspensionController.text = widget.build['suspension']?.toString() ?? '';
    _brakesController.text = widget.build['brakes']?.toString() ?? '';
    _selectedCategory = widget.build['build_category']?.toString();
    final mediaRaw = widget.build['additional_media'] ??
        widget.build['additional_images'] ??
        [];

    _existingAdditionalMedia = [];
    for (var item in mediaRaw) {
      if (item is String) {
        _existingAdditionalMedia.add({'url': item, 'type': 'image'});
      } else if (item is Map) {
        final mediaMap = Map<String, dynamic>.from(item);
        if (!mediaMap.containsKey('type')) {
          mediaMap['type'] = 'image';
        }
        _existingAdditionalMedia.add(mediaMap);
      }
    }
  }

  Future<void> _pickImage() async {
    final File? selected = await pickImageFromGallery();

    if (selected != null) {
      setState(() {
        _selectedImage = selected;
        widget.build['image'] = selected.path;
      });
    }
  }

  void _removeAdditionalMedia(int index) {
    setState(() {
      removedAdditionalMedia.add(_existingAdditionalMedia[index]['url']!);
      _existingAdditionalMedia.removeAt(index);
    });
  }

Future<void> _pickAdditionalMedia() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickMedia();
  if (pickedFile != null) {
    final String lowerCasePath = pickedFile.path.toLowerCase();
    final String extension = lowerCasePath.split('.').last;
    final String fileType = (lowerCasePath.endsWith(".mp4") ||
            lowerCasePath.endsWith(".mov"))
        ? "video"
        : "image";
    setState(() {
      newAdditionalMedia.add(
        AdditionalMedia(
          file: File(pickedFile.path),
          type: fileType,
          extension: extension,
        ),
      );
    });
  }
}

  Future<void> _updateBuild() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = <String, String>{
      'year': _yearController.text.trim(),
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'trim': _trimController.text.trim(),
      'build_category': _selectedCategory ?? '',
      'hp': _hpController.text.trim(),
      'whp': _whpController.text.trim(),
      'torque': _torqueController.text.trim(),
      'weight': _weightController.text.trim(),
      'vehicleLayout': _vehicleLayoutController.text.trim(),
      'fuel': _fuelController.text.trim(),
      'zeroSixty': _zeroSixtyController.text.trim(),
      'zeroOneHundred': _zeroOneHundredController.text.trim(),
      'quarterMile': _quarterMileController.text.trim(),
      'engineType': _engineTypeController.text.trim(),
      'engineCode': _engineCodeController.text.trim(),
      'forcedInduction': _forcedInductionController.text.trim(),
      'trans': _transController.text.trim(),
      'suspension': _suspensionController.text.trim(),
      'brakes': _brakesController.text.trim(),
    };

    Uint8List? imageBytes;
    if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
    }

    List<Uint8List>? additionalMediaBytes;
    List<String>? additionalMediaTypes;
    if (newAdditionalMedia.isNotEmpty) {
      additionalMediaBytes = [];
      additionalMediaTypes = [];
      for (final media in newAdditionalMedia) {
        additionalMediaBytes.add(await media.file.readAsBytes());
        additionalMediaTypes.add(media.type);
      }
    }

    final removedMedia =
        removedAdditionalMedia.isNotEmpty ? removedAdditionalMedia : null;

    final updatedBuild = await updateBuild(
      context,
      buildId: widget.build['id'].toString(),
      fields: fields,
      imageBytes: imageBytes,
      additionalMediaBytes: additionalMediaBytes,
      removedImages: removedMedia,
    );

    if (updatedBuild != null) {
      Navigator.pop(context, updatedBuild);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Build'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmDelete = await showDeleteDialog(context, 'build');
              if (confirmDelete) {
                final success = await deleteBuild(
                  context,
                  buildId: widget.build['id'].toString(),
                );
                if (success) {
                  Navigator.popUntil(context, ModalRoute.withName('/garage'));
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _yearController,
                  label: 'Year*',
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _makeController,
                  label: 'Make*',
                  isRequired: true,
                ),
                _buildTextField(
                  controller: _modelController,
                  label: 'Model*',
                  isRequired: true,
                ),
                _buildTextField(controller: _trimController, label: 'Trim'),
                _buildDropdownField(),
                _buildTextField(
                    controller: _hpController, label: 'Horsepower (HP)'),
                _buildTextField(
                    controller: _whpController,
                    label: 'Wheel Horsepower (WHP)'),
                _buildTextField(controller: _torqueController, label: 'Torque'),
                _buildTextField(controller: _weightController, label: 'Weight'),
                _buildTextField(
                    controller: _vehicleLayoutController,
                    label: 'Vehicle Layout'),
                _buildTextField(controller: _fuelController, label: 'Fuel'),
                _buildTextField(
                    controller: _zeroSixtyController, label: '0-60 mph Time'),
                _buildTextField(
                    controller: _zeroOneHundredController,
                    label: '0-100 mph Time'),
                _buildTextField(
                    controller: _quarterMileController,
                    label: 'Quarter Mile Time'),
                _buildTextField(
                    controller: _engineTypeController, label: 'Engine Type'),
                _buildTextField(
                    controller: _engineCodeController, label: 'Engine Code'),
                _buildTextField(
                    controller: _forcedInductionController,
                    label: 'Forced Induction'),
                _buildTextField(
                    controller: _transController, label: 'Transmission'),
                _buildTextField(
                    controller: _suspensionController, label: 'Suspension'),
                _buildTextField(controller: _brakesController, label: 'Brakes'),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Featured image preview container
                    if (_selectedImage != null)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else if (widget.build['image'] != null)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(widget.build['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Replace Featured Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Media',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Existing Additional Media Preview
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _existingAdditionalMedia.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mediaItem = entry.value;
                    final mediaUrl = mediaItem['url'] ?? '';
                    final mediaType = mediaItem['type'] ?? 'image';
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            // If the existing media is an image, show it; otherwise show a video icon.
                            image: mediaType == 'image'
                                ? DecorationImage(
                                    image: NetworkImage(mediaUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: mediaType == 'video'
                              ? const Center(
                                  child: Icon(Icons.videocam,
                                      size: 40, color: Colors.grey),
                                )
                              : null,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeAdditionalMedia(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                // Button to pick new additional media (image or video)
                ElevatedButton(
                  onPressed: _pickAdditionalMedia,
                  child: const Text('Add Additional Media'),
                ),
                const SizedBox(height: 10),
                // Preview of newly picked additional media
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: newAdditionalMedia.asMap().entries.map((entry) {
                    final index = entry.key;
                    final media = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            // For images, show a preview; for videos, display a placeholder icon.
                            image: media.type == 'image'
                                ? DecorationImage(
                                    image: FileImage(media.file),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: media.type == 'video'
                              ? const Center(
                                  child: Icon(Icons.videocam,
                                      size: 40, color: Colors.grey),
                                )
                              : null,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                newAdditionalMedia.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _updateBuild,
                  child: const Text('Update Build'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: isRequired
          ? (value) =>
              value == null || value.isEmpty ? '$label is required' : null
          : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Build Category'),
      value: _selectedCategory,
      items: staticCategories
          .map((category) =>
              DropdownMenuItem(value: category, child: Text(category)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Category is required' : null,
    );
  }
}
