// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  List<String> _existingAdditionalImages = [];
  List<String> _removedAdditionalImages = [];
  List<File> _newAdditionalImages = [];

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
    _existingAdditionalImages =
        List<String>.from(widget.build['additional_images'] ?? []);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        widget.build['image'] = pickedFile.path;
      });
    }
  }

  void _removeAdditionalImage(int index) {
    setState(() {
      _removedAdditionalImages.add(_existingAdditionalImages[index]);
      _existingAdditionalImages.removeAt(index);
    });
  }

  Future<void> _pickAdditionalImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newAdditionalImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _updateBuild() async {
    if (!_formKey.currentState!.validate()) {
      // Form validation failed exception goes here...
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not authenticated')),
      );
      return;
    }

    final url =
        'https://passiondrivenbuilds.com/api/builds/${widget.build['id']}';

    try {
      final body = {
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
        'removed_images':
            _removedAdditionalImages.isNotEmpty ? _removedAdditionalImages : [],
      };

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        body['image'] = base64Encode(bytes);
      }

      if (_newAdditionalImages.isNotEmpty) {
        final List<String> newImagesBase64 = [];
        for (final file in _newAdditionalImages) {
          final bytes = await file.readAsBytes();
          newImagesBase64.add(base64Encode(bytes));
        }
        body['added_images'] = newImagesBase64;
      }

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final updatedBuild = jsonDecode(response.body)['build'];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Build updated successfully!')),
        );

        Navigator.pop(context, updatedBuild);
      } else {
        final error =
            jsonDecode(response.body)['message'] ?? 'An error occurred';
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
      appBar: AppBar(title: const Text('Edit Build')),
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
                    isRequired: true),
                _buildTextField(
                    controller: _makeController,
                    label: 'Make*',
                    isRequired: true),
                _buildTextField(
                    controller: _modelController,
                    label: 'Model*',
                    isRequired: true),
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
                    // Image preview container
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
                  'Additional Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Additional Images',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Additional Images
                ElevatedButton(
                  onPressed: _pickAdditionalImage,
                  child: const Text('Add Additional Image'),
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      _existingAdditionalImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final imageUrl = entry.value;

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeAdditionalImage(index),
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

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _newAdditionalImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value; // A File from ImagePicker

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(file),
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
                                _newAdditionalImages.removeAt(index);
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      bool isRequired = false}) {
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
      items: _categories
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
