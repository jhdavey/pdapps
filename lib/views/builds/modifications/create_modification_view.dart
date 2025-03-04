// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
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

  Future<void> _submitModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final success = await submitModification(
      context,
      widget.buildId.toString(),
      category: _selectedCategory!,
      name: _name,
      brand: _brand,
      price: _price,
      part: _part,
      notes: _notes,
      installedMyself: _installedMyself,
      installedBy: _installedMyself == 1 ? null : _installedBy,
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

    final success = await submitModification(
      context,
      widget.buildId.toString(),
      category: _selectedCategory!,
      name: _name,
      brand: _brand,
      price: _price,
      part: _part,
      notes: _notes,
      installedMyself: _installedMyself,
      installedBy: _installedMyself == 1 ? null : _installedBy,
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
      });
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
              _buildTextField('Brand*', (value) => _brand = value),
              const SizedBox(height: 16),
              _buildTextField('Price', (value) => _price = value,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              _buildTextField('Part Number', (value) => _part = value),
              const SizedBox(height: 16),
              _buildTextField('Notes', (value) => _notes = value, maxLines: 4),
              const SizedBox(height: 16),
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
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitModification,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Submit Modification'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        _isSubmitting ? null : _submitAndAddAnotherModification,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
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
        if ((label == 'Name' || label == 'Brand') &&
            (value == null || value.isEmpty)) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}
