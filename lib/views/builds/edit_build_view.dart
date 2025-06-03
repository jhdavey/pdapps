// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _whpController = TextEditingController();
  final TextEditingController _torqueController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _zeroSixtyController = TextEditingController();
  final TextEditingController _quarterMileController = TextEditingController();
  final TextEditingController _engineTypeController = TextEditingController();
  final TextEditingController _forcedInductionController =
      TextEditingController();
  final TextEditingController _transController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

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
    _whpController.text = widget.build['whp']?.toString() ?? '';
    _torqueController.text = widget.build['torque']?.toString() ?? '';
    _weightController.text = widget.build['weight']?.toString() ?? '';
    widget.build['vehicleLayout']?.toString() ?? '';
    _zeroSixtyController.text = widget.build['zeroSixty']?.toString() ?? '';
    widget.build['zeroOneHundred']?.toString() ?? '';
    _quarterMileController.text = widget.build['quarterMile']?.toString() ?? '';
    _engineTypeController.text = widget.build['engineType']?.toString() ?? '';
    _forcedInductionController.text =
        widget.build['forcedInduction']?.toString() ?? '';
    _transController.text = widget.build['trans']?.toString() ?? '';
    _selectedCategory = widget.build['build_category']?.toString();

    if (widget.build['tags'] != null && widget.build['tags'] is List) {
      List<dynamic> tagsList = widget.build['tags'];
      _tagsController.text = tagsList.map((tag) => tag['name']).join(', ');
    }

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
        // Only add media if it is an image.
        if (mediaMap['type'] == 'image') {
          _existingAdditionalMedia.add(mediaMap);
        }
      }
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _trimController.dispose();
    _whpController.dispose();
    _torqueController.dispose();
    _weightController.dispose();
    _zeroSixtyController.dispose();
    _quarterMileController.dispose();
    _engineTypeController.dispose();
    _forcedInductionController.dispose();
    _transController.dispose();
    _tagsController.dispose();
    super.dispose();
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
    // Only allow picking images.
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final String lowerCasePath = pickedFile.path.toLowerCase();
      final String extension = lowerCasePath.split('.').last;
      // Validate the file extension to allow only image files.
      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      if (!allowedExtensions.contains(extension)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only image files are allowed.')),
        );
        return;
      }
      setState(() {
        newAdditionalMedia.add(
          AdditionalMedia(
            file: File(pickedFile.path),
            type: "image",
            extension: extension,
          ),
        );
      });
    }
  }

  Future<void> _updateBuild() async {
    if (!_formKey.currentState!.validate()) return;

    // Use Map<String, dynamic> so that arrays are preserved.
    final fields = <String, dynamic>{
      'year': _yearController.text.trim(),
      'make': _makeController.text.trim(),
      'model': _modelController.text.trim(),
      'trim': _trimController.text.trim(),
      'build_category': _selectedCategory ?? '',
      'whp': _whpController.text.trim(),
      'torque': _torqueController.text.trim(),
      'weight': _weightController.text.trim(),
      'zeroSixty': _zeroSixtyController.text.trim(),
      'quarterMile': _quarterMileController.text.trim(),
      'engineType': _engineTypeController.text.trim(),
      'forcedInduction': _forcedInductionController.text.trim(),
      'trans': _transController.text.trim(),
    };

    final tagsInput = _tagsController.text;
    final List<String> tags = tagsInput
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    if (tags.isNotEmpty) {
      fields['tags'] = tags;
    }

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
      additionalMediaTypes: additionalMediaTypes,
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
                TextFormField(
                  controller: _whpController,
                  decoration: const InputDecoration(
                    labelText: 'Wheel Horsepower (numbers only)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _torqueController,
                  decoration: const InputDecoration(
                    labelText: 'Torque (numbers only)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                _buildTextField(controller: _weightController, label: 'Weight'),
                _buildTextField(
                    controller: _zeroSixtyController, label: '0-60 mph Time'),
                _buildTextField(
                    controller: _quarterMileController,
                    label: 'Quarter Mile Time'),
                _buildTextField(
                    controller: _engineTypeController, label: 'Engine Type'),
                _buildTextField(
                    controller: _forcedInductionController,
                    label: 'Forced Induction'),
                _buildTextField(
                    controller: _transController, label: 'Transmission'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                  'Additional Featured Media',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Existing Additional Featured Media Preview.
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _existingAdditionalMedia.asMap().entries.map((entry) {
                    final index = entry.key;
                    final mediaItem = entry.value;
                    final mediaUrl = mediaItem['url'] ?? '';
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(mediaUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                // Button to pick new additional media (images only).
                ElevatedButton(
                  onPressed: _pickAdditionalMedia,
                  child: const Text('Add Additional Featured Media'),
                ),
                const SizedBox(height: 10),
                // Preview of newly picked additional media.
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
                            image: DecorationImage(
                              image: FileImage(media.file),
                              fit: BoxFit.cover,
                            ),
                          ),
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
