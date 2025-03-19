// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
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
  late String? _name;
  late String? _brand;
  String? _price;
  String? _part;
  String? _notes; // Modification notes field
  bool _isSubmitting = false;
  int _installedMyself = 0;
  String? _installedBy;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.modification['category'] ?? categories.first;
    _name = widget.modification['name'] ?? '';
    _brand = widget.modification['brand'] ?? '';
    _price = widget.modification['price']?.toString();
    _part = widget.modification['part'] ?? '';
    _notes =
        widget.modification['notes'] ?? ''; // Initialize modification notes
    _installedMyself = widget.modification['installed_myself'] ?? 0;
    _installedBy = widget.modification['installed_by'] ?? '';
  }

  Future<void> _submitModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final modificationData = {
      'category': _selectedCategory,
      'name': _name,
      'brand': _brand,
      'price': _price,
      'part': _part,
      'notes': _notes, // Include modification notes
      'installedMyself': _installedMyself,
      'installed_by': _installedMyself == 1 ? null : _installedBy,
    };

    final success = await updateModification(
      context: context,
      buildId: widget.buildId,
      modificationId: widget.modification['id'],
      modificationData: modificationData,
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
              _buildTextField('Name*', _name, (value) => _name = value),
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
              // New text field for modification notes with 4 lines max.
              _buildTextField(
                'Notes',
                _notes,
                (value) => _notes = value,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Installed Myself'),
                value: _installedMyself == 1,
                onChanged: (bool? value) {
                  setState(() {
                    _installedMyself = value == true ? 1 : 0;
                    if (_installedMyself == 1) _installedBy = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Installed By',
                _installedBy,
                (value) => _installedBy = value,
                enabled: _installedMyself == 0,
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
                        : const Text('Update Modification'),
                  ),
                ],
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
        if ((label.contains('Name')) &&
            (value == null || value.isEmpty)) {
          return 'Please enter a $label';
        }
        return null;
      },
    );
  }
}
