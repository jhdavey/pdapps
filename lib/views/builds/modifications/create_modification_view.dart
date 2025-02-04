import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/data/modification_categories.dart';
import 'package:pd/services/api/auth_service.dart';

class CreateModificationView extends StatefulWidget {
  final int buildId;
  const CreateModificationView({Key? key, required this.buildId})
      : super(key: key);

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

  Future<void> _submitModification() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isSubmitting = true;
    });

    // Retrieve the token from ApiAuthService.
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();

    final String apiUrl =
        'https://passiondrivenbuilds.com/api/builds/${widget.buildId}/modifications';

    // Build the modification data.
    final Map<String, dynamic> modificationData = {
      'category': _selectedCategory,
      'name': _name,
      'brand': _brand,
      'price': _price,
      'part': _part,
      'notes': _notes,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(modificationData),
      );

      if (response.statusCode == 201) {
        // Modification added successfully.
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
                    _selectedCategory = value;
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
                onSaved: (value) => _part = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitModification,
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Submit Modification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
