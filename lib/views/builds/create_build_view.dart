import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateBuildView extends StatefulWidget {
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

    // Retrieve the token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not authenticated')),
      );
      return;
    }

    final url = 'https://passiondrivenbuilds.com/api/builds';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['year'] = _yearController.text;
      request.fields['make'] = _makeController.text;
      request.fields['model'] = _modelController.text;
      request.fields['build_category'] = _selectedCategory!;

      if (_selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _selectedImage!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Build created successfully!')),
        );
        Navigator.pop(context);
      } else {
        final responseBody = await response.stream.bytesToString();
        final error = jsonDecode(responseBody)['message'] ?? 'An error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
