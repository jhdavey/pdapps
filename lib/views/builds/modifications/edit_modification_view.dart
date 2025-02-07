// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/data/modification_categories.dart';
import 'package:pd/services/api/build/modification/edit_modification.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class EditModificationView extends StatefulWidget {
  final int buildId;
  final Map<String, dynamic> modification;

  const EditModificationView({
    Key? key,
    required this.buildId,
    required this.modification,
  }) : super(key: key);

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
  String? _notes;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.modification['category'] ?? categories.first;
    _name = widget.modification['name'] ?? '';
    _brand = widget.modification['brand'] ?? '';
    _price = widget.modification['price']?.toString();
    _part = widget.modification['part'] ?? '';
    _notes = widget.modification['notes'] ?? '';
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
      'notes': _notes,
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
    final confirm = await showDeleteDialog(context);
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
                  labelText: 'Category',
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
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField('Name', _name, (value) => _name = value),
              const SizedBox(height: 16),
              _buildTextField('Brand', _brand, (value) => _brand = value),
              const SizedBox(height: 16),
              _buildTextField('Price', _price, (value) => _price = value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              _buildTextField('Part Number', _part, (value) => _part = value),
              const SizedBox(height: 16),
              _buildTextField('Notes', _notes, (value) => _notes = value, maxLines: 4),
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
      String label, String? initialValue, Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      initialValue: initialValue,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: (value) =>
          (label == 'Name' || label == 'Brand') && (value == null || value.isEmpty)
              ? 'Please enter a $label'
              : null,
    );
  }
}
