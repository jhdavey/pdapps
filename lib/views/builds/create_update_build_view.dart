import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateUpdateBuildView extends StatefulWidget {
  final Map<String, dynamic>? build;

  const CreateUpdateBuildView({super.key, this.build});

  @override
  _CreateUpdateBuildViewState createState() => _CreateUpdateBuildViewState();
}

class _CreateUpdateBuildViewState extends State<CreateUpdateBuildView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController yearController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController trimController = TextEditingController();
  final TextEditingController hpController = TextEditingController();
  final TextEditingController whpController = TextEditingController();
  final TextEditingController torqueController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController vehicleLayoutController = TextEditingController();
  final TextEditingController fuelController = TextEditingController();
  final TextEditingController zeroSixtyController = TextEditingController();
  final TextEditingController zeroOneHundredController = TextEditingController();
  final TextEditingController quarterMileController = TextEditingController();
  final TextEditingController engineTypeController = TextEditingController();
  final TextEditingController engineCodeController = TextEditingController();
  final TextEditingController forcedInductionController = TextEditingController();
  final TextEditingController transController = TextEditingController();
  final TextEditingController suspensionController = TextEditingController();
  final TextEditingController brakesController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  String? buildCategory;
  File? imageFile;

  // List of build categories
  final List<String> buildCategories = [
    'Classic/Antique',
    'Drag',
    'Drift',
    'Exotic',
    'Hot rod/Rat rod',
    'Lowrider',
    'Luxury/VIP',
    'Muscle',
    'Offroad/Overlander',
    'Rally',
    'Restomod',
    'Show',
    'Sleeper',
    'Stanced',
    'Street/daily',
    'Time attack',
    'Track/circuit/road race',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.build != null) {
      // Populate fields if editing an existing build
      final build = widget.build!;
      yearController.text = build['year'] ?? '';
      makeController.text = build['make'] ?? '';
      modelController.text = build['model'] ?? '';
      trimController.text = build['trim'] ?? '';
      buildCategory = build['build_category'];
      hpController.text = build['hp'] ?? '';
      whpController.text = build['whp'] ?? '';
      torqueController.text = build['torque'] ?? '';
      weightController.text = build['weight'] ?? '';
      vehicleLayoutController.text = build['vehicleLayout'] ?? '';
      fuelController.text = build['fuel'] ?? '';
      zeroSixtyController.text = build['zeroSixty'] ?? '';
      zeroOneHundredController.text = build['zeroOneHundred'] ?? '';
      quarterMileController.text = build['quarterMile'] ?? '';
      engineTypeController.text = build['engineType'] ?? '';
      engineCodeController.text = build['engineCode'] ?? '';
      forcedInductionController.text = build['forcedInduction'] ?? '';
      transController.text = build['trans'] ?? '';
      suspensionController.text = build['suspension'] ?? '';
      brakesController.text = build['brakes'] ?? '';
      tagsController.text = build['tags'] ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveBuild() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final uri = widget.build == null
        ? Uri.parse('https://passiondrivenbuilds.com/api/builds')
        : Uri.parse('https://passiondrivenbuilds.com/api/builds/${widget.build!['id']}');

    final request = http.MultipartRequest(
      widget.build == null ? 'POST' : 'PATCH',
      uri,
    );

    final token = 'YOUR_AUTH_TOKEN'; // Replace with actual token retrieval logic

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'application/json';

    // Add form fields
    request.fields.addAll({
      'year': yearController.text,
      'make': makeController.text,
      'model': modelController.text,
      'trim': trimController.text,
      'build_category': buildCategory ?? '',
      'hp': hpController.text,
      'whp': whpController.text,
      'torque': torqueController.text,
      'weight': weightController.text,
      'vehicleLayout': vehicleLayoutController.text,
      'fuel': fuelController.text,
      'zeroSixty': zeroSixtyController.text,
      'zeroOneHundred': zeroOneHundredController.text,
      'quarterMile': quarterMileController.text,
      'engineType': engineTypeController.text,
      'engineCode': engineCodeController.text,
      'forcedInduction': forcedInductionController.text,
      'trans': transController.text,
      'suspension': suspensionController.text,
      'brakes': brakesController.text,
      'tags': tagsController.text,
    });

    // Add image file if selected
    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile!.path));
    }

    // Send the request
    final response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('Build saved successfully');
      Navigator.pop(context);
    } else {
      print('Failed to save build: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.build == null ? 'Create Build' : 'Edit Build'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                validator: (value) => value == null || value.isEmpty ? 'Year is required' : null,
              ),
              TextFormField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make'),
                validator: (value) => value == null || value.isEmpty ? 'Make is required' : null,
              ),
              TextFormField(
                controller: modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) => value == null || value.isEmpty ? 'Model is required' : null,
              ),
              TextFormField(
                controller: trimController,
                decoration: const InputDecoration(labelText: 'Trim Level'),
              ),
              DropdownButtonFormField<String>(
                value: buildCategory,
                items: buildCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => buildCategory = value),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value == null || value.isEmpty ? 'Category is required' : null,
              ),
              TextFormField(
                controller: hpController,
                decoration: const InputDecoration(labelText: 'HP'),
              ),
              // Additional fields go here...
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveBuild,
                child: Text(widget.build == null ? 'Create Build' : 'Update Build'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
