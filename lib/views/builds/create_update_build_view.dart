// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/auth/auth_service.dart';
import 'package:pd/services/local_database.dart';

class CreateUpdateBuildView extends StatefulWidget {
  const CreateUpdateBuildView({super.key});

  @override
  _CreateUpdateBuildViewState createState() => _CreateUpdateBuildViewState();
}

class _CreateUpdateBuildViewState extends State<CreateUpdateBuildView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final LocalDatabase _localDatabase = LocalDatabase.instance;

  Future<void> _saveBuild() async {
    if (_formKey.currentState!.validate()) {
      final userId = AuthService.instance.currentUser?.id ?? '';
      final make = _makeController.text;
      final model = _modelController.text;
      final year = int.tryParse(_yearController.text) ?? 0;

      final db = await _localDatabase.database;
      await db.insert('builds', {
        'make': make,
        'model': model,
        'year': year,
        'userId': userId,
      });

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Build'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _makeController,
                decoration: const InputDecoration(labelText: 'Make'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the make';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveBuild,
                child: const Text('Save Build'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}