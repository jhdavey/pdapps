// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/data/modification_categories.dart';
import 'package:pd/services/api/build/modification/edit_modification.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class EditModificationView extends StatefulWidget {
  final int buildId;
  final Map<String, dynamic> modification;

  const EditModificationView({
    super.key,
    required this.buildId,
    required this.modification,
  });

  @override
  _EditModificationViewState createState() => _EditModificationViewState();
}

class _EditModificationViewState extends State<EditModificationView> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedCategory;
  late TextEditingController _nameController;
  late String? _brand;
  String? _price;
  String? _part;
  String? _notes;
  bool _isSubmitting = false;
  int _installedMyself = 0;
  String? _installedBy;
  // New flag for not installed status
  late bool _notInstalled;

  // State for managing images.
  late List<String> _existingImages;
  final List<XFile> _newImages = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.modification['category'] ?? categories.first;
    _nameController =
        TextEditingController(text: widget.modification['name'] ?? '');
    _brand = widget.modification['brand'] ?? '';
    _price = widget.modification['price']?.toString();
    _part = widget.modification['part'] ?? '';
    _notes = widget.modification['notes'] ?? '';
    _installedMyself = widget.modification['installed_myself'] ?? 0;
    _installedBy = widget.modification['installed_by'] ?? '';
    // Initialize _notInstalled from API (assumed to be 1/true for not installed, 0/false for installed)
    _notInstalled = (widget.modification['not_installed'] == 1 ||
        widget.modification['not_installed'] == true);
    if (widget.modification['images'] != null &&
        widget.modification['images'] is List) {
      _existingImages = List<String>.from(widget.modification['images']);
    } else {
      _existingImages = [];
    }
  }

  /// Call this whenever installation fields change.
  void _updateNotInstalledStatus() {
    setState(() {
      // If either installedMyself is set or an installedBy value is provided, mark as installed.
      if (_installedMyself == 1 || (_installedBy != null && _installedBy!.trim().isNotEmpty)) {
        _notInstalled = false;
      } else {
        _notInstalled = true;
      }
    });
  }

  Future<void> _pickNewImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles);
      });
    }
  }

  Widget _buildExistingImages() {
    if (_existingImages.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Existing Images:', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _existingImages.length,
            itemBuilder: (context, index) {
              final url = _existingImages[index];
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _existingImages.removeAt(index);
                        });
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
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
  }

  Widget _buildNewImages() {
    if (_newImages.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Images:', style: TextStyle(color: Colors.white)),
        const SizedBox(height: 4),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _newImages.length,
            itemBuilder: (context, index) {
              final file = _newImages[index];
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(
                      File(file.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _newImages.removeAt(index);
                        });
                      },
                      child: Container(
                        color: Colors.black45,
                        child: const Icon(Icons.close, size: 18, color: Colors.red),
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
  }

  Future<void> _submitModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final effectiveName = _nameController.text.trim();
    if (effectiveName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Modification name cannot be empty.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Update the not-installed flag based on current fields.
    _updateNotInstalledStatus();

    // Build the modification data to send.
    final modificationData = {
      'category': _selectedCategory,
      'name': effectiveName,
      'brand': _brand,
      'price': _price,
      'part': _part,
      'notes': _notes,
      'installedMyself': _installedMyself,
      'installed_by': _installedMyself == 1 ? null : _installedBy,
      'existing_images': _existingImages,
      'not_installed': _notInstalled ? 1 : 0,
    };

    debugPrint("Modification data: $modificationData");

    final success = await updateModification(
      context: context,
      buildId: widget.buildId,
      modificationId: widget.modification['id'],
      modificationData: modificationData,
      newImages: _newImages,
    );

    if (success) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteModification() async {
    final confirm = await showDeleteDialog(context, 'modification');
    if (!confirm) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await deleteModification(
      context: context,
      buildId: widget.buildId,
      modificationId: widget.modification['id'],
    );

    if (success) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Modification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isSubmitting ? null : _deleteModification,
            color: const Color(0xFFED1C24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category*' : null,
              ),
              const SizedBox(height: 16),
              // Name field with controller.
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Name';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Value is in controller.
                },
              ),
              const SizedBox(height: 16),
              _buildTextField('Brand', _brand, (value) => _brand = value),
              const SizedBox(height: 16),
              _buildTextField(
                'Price',
                _price,
                (value) => _price = value,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              _buildTextField('Part Number', _part, (value) => _part = value),
              const SizedBox(height: 16),
              _buildTextField('Notes', _notes, (value) => _notes = value, maxLines: 4),
              const SizedBox(height: 16),
              // Display the "Not Installed" indicator if applicable.
              if (_notInstalled)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Not Installed",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Installed Myself'),
                value: _installedMyself == 1,
                onChanged: (bool? value) {
                  setState(() {
                    _installedMyself = value == true ? 1 : 0;
                    if (_installedMyself == 1) _installedBy = null;
                    _updateNotInstalledStatus();
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Installed By',
                  border: OutlineInputBorder(),
                ),
                enabled: _installedMyself == 0,
                initialValue: _installedBy,
                onChanged: (value) {
                  setState(() {
                    _installedBy = value;
                    _updateNotInstalledStatus();
                  });
                },
              ),
              const SizedBox(height: 16),
              // Section to manage images.
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Add Images'),
                  onPressed: _pickNewImages,
                ),
              ),
              const SizedBox(height: 8),
              _buildExistingImages(),
              const SizedBox(height: 8),
              _buildNewImages(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitModification,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Modification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String? initialValue,
    Function(String?) onSaved, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      enabled: enabled,
      validator: (value) {
        if (label.contains('Name') && (value == null || value.trim().isEmpty)) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}
