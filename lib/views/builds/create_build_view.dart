import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/build/create_build.dart';

class CreateBuildView extends StatefulWidget {
  const CreateBuildView({super.key});

  @override
  _CreateBuildViewState createState() => _CreateBuildViewState();
}

class _CreateBuildViewState extends State<CreateBuildView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _selectedCategory;
  File? _selectedImage;

  final List<String> _categories = [
    'Classic/Antique',
    'Drag',
    'Drift',
    'Exotic',
    'Hot rod/Rat rod',
    'Lowrider',
    'Mudder',
    'Muscle',
    'Offroad/Overlander',
    'Rally',
    'Restomod',
    'Show',
    'Sleeper',
    'Stance',
    'Street/daily',
    'Time attack',
    'Track/circuit/road race',
    'VIP',
    'Other',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _createBuild() async {
    if (!_formKey.currentState!.validate()) return;

    // Build the basic fields.
    final fields = <String, String>{
      'year': _yearController.text,
      'make': _makeController.text,
      'model': _modelController.text,
      'build_category': _selectedCategory!,
    };

    // Process tags input: split by comma and remove empty parts.
    final tagsInput = _tagsController.text;
    final List<String> tags = tagsInput.split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    if (tags.isNotEmpty) {
      // Encode the list as a JSON string.
      fields['tags'] = jsonEncode(tags);
    }

    final success = await createBuild(
      context,
      fields: fields,
      imageFile: _selectedImage,
    );

    if (success) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Build')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Year *'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Year is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _makeController,
                  decoration: const InputDecoration(labelText: 'Make *'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Make is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model *'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Model is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Build Category *'),
                  value: _selectedCategory,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Category is required' : null,
                ),
                const SizedBox(height: 12),
                // New input field for tags.
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma-separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // Preview of the selected featured image.
                if (_selectedImage != null)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pick Featured Image'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add additional details and media by editing your build after creating it.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _createBuild,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create Build'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
