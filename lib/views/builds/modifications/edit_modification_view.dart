// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/data/modification_categories.dart';
import 'package:pd/services/api/build/modification/edit_modification.dart';

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
    // Pre-fill form fields using the modification data.
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

    // Build the data to update.
    final Map<String, dynamic> modificationData = {
      'category': _selectedCategory,
      'name': _name,
      'brand': _brand,
      'price': _price,
      'part': _part,
      'notes': _notes,
    };

    final int modificationId = widget.modification['id'];

    // Call the extracted API function.
    final success = await updateModification(
      context: context,
      buildId: widget.buildId,
      modificationId: modificationId,
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
    // Confirm deletion with a dialog.
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Modification'),
        content:
            const Text('Are you sure you want to delete this modification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() {
      _isSubmitting = true;
    });

    final int modificationId = widget.modification['id'];

    // Call the extracted delete function.
    final success = await deleteModification(
      context: context,
      buildId: widget.buildId,
      modificationId: modificationId,
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
            color: Color(0xFFED1C24),
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
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                initialValue: _name,
                onSaved: (value) => _name = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                initialValue: _brand,
                onSaved: (value) => _brand = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a brand'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                initialValue: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _price = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Part Number',
                  border: OutlineInputBorder(),
                ),
                initialValue: _part,
                onSaved: (value) => _part = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                initialValue: _notes,
                maxLines: 4,
                onSaved: (value) => _notes = value,
              ),
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
}
