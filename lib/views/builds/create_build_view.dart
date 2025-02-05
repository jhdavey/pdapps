// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/builds/build_create.dart';

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

  final fields = <String, String>{
    'year': _yearController.text,
    'make': _makeController.text,
    'model': _modelController.text,
    'build_category': _selectedCategory!,
  };

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
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Year is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _makeController,
                  decoration: const InputDecoration(labelText: 'Make *'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Make is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _modelController,
                  decoration: const InputDecoration(labelText: 'Model *'),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Model is required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Build Category *'),
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
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Category is required'
                      : null,
                ),
                const SizedBox(height: 12),
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
                const Center(
                  child: Text(
                    'Add additional details by editing your build',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
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
