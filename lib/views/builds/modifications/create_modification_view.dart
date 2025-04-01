// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/data/modification_categories.dart';
import 'package:pd/services/api/build/modification/create_modification.dart';

class CreateModificationView extends StatefulWidget {
  final int buildId;
  const CreateModificationView({super.key, required this.buildId});

  @override
  _CreateModificationViewState createState() => _CreateModificationViewState();
}

class _CreateModificationViewState extends State<CreateModificationView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _name;
  String? _brand;
  String? _price;
  String? _part;
  String? _notes;
  bool _isSubmitting = false;
  int _installedMyself = 0;
  String? _installedBy;
  bool _notInstalled = false; // New state variable for "Not Yet Installed"
  final List<XFile> _selectedImages = []; // For storing picked images

  // Use ImagePicker to pick multiple images.
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles);
      });
    }
  }

  // Build thumbnails for selected images.
  Widget _buildSelectedImages() {
    if (_selectedImages.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                Image.file(
                  File(_selectedImages[index].path),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    // When "Not Yet Installed" is checked, force installed fields to null/0.
    final installedMyself = _notInstalled ? 0 : _installedMyself;
    final installedBy = _notInstalled ? null : _installedBy;

    final success = await submitModification(
      context,
      widget.buildId.toString(),
      category: _selectedCategory!,
      name: _name,
      brand: _brand,
      price: _price,
      part: _part,
      notes: _notes,
      installedMyself: installedMyself,
      installedBy: installedBy,
      images: _selectedImages,
      notInstalled: _notInstalled ? 1 : 0,
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

  Future<void> _submitAndAddAnotherModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final installedMyself = _notInstalled ? 0 : _installedMyself;
    final installedBy = _notInstalled ? null : _installedBy;

    final success = await submitModification(
      context,
      widget.buildId.toString(),
      category: _selectedCategory!,
      name: _name,
      brand: _brand,
      price: _price,
      part: _part,
      notes: _notes,
      installedMyself: installedMyself,
      installedBy: installedBy,
      images: _selectedImages,
      notInstalled: _notInstalled ? 1 : 0,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modification submitted. You can add another.'),
        ),
      );
      _formKey.currentState!.reset();
      setState(() {
        _selectedCategory = null;
        _name = null;
        _brand = null;
        _price = null;
        _part = null;
        _notes = null;
        _installedMyself = 0;
        _installedBy = null;
        _notInstalled = false;
        _selectedImages.clear();
      });
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildTextField(
    String label,
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
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      enabled: enabled,
      validator: (value) {
        if (label.contains('Name') && (value == null || value.isEmpty)) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Modification'),
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
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category*' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField('Name*', (value) => _name = value),
              const SizedBox(height: 16),
              _buildTextField('Brand', (value) => _brand = value),
              const SizedBox(height: 16),
              _buildTextField(
                'Price',
                (value) => _price = value,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              _buildTextField('Part Number', (value) => _part = value),
              const SizedBox(height: 16),
              _buildTextField('Notes', (value) => _notes = value, maxLines: 4),
              const SizedBox(height: 16),
              // New checkbox for "Not Yet Installed"
              CheckboxListTile(
                title: const Text('Not Yet Installed'),
                value: _notInstalled,
                onChanged: (bool? value) {
                  setState(() {
                    _notInstalled = value ?? false;
                    if (_notInstalled) {
                      // Clear installation details if not installed.
                      _installedMyself = 0;
                      _installedBy = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              // Only show installed info if "Not Yet Installed" is false.
              if (!_notInstalled) ...[
                CheckboxListTile(
                  title: const Text('Installed Myself'),
                  value: _installedMyself == 1,
                  onChanged: (bool? value) {
                    setState(() {
                      _installedMyself = value == true ? 1 : 0;
                      if (_installedMyself == 1) {
                        _installedBy = null;
                      }
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
                  onChanged: (value) {
                    if (_installedMyself == 0) {
                      _installedBy = value;
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Section to pick and display images.
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Add Images'),
                  onPressed: _pickImages,
                ),
              ),
              const SizedBox(height: 8),
              _buildSelectedImages(),
              const SizedBox(height: 16),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitModification,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Modification'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAndAddAnotherModification,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit and Add Another'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
