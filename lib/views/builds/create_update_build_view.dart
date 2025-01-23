import 'package:flutter/material.dart';
import 'package:pd/models/build.dart';
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

  bool _isEdit = false;
  int? _editingBuildId;
  bool _didLoadArguments = false; // track if we've processed arguments

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadArguments) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _isEdit = args['isEdit'] as bool;
        _editingBuildId = args['buildId'] as int?;
        if (_isEdit && _editingBuildId != null) {
          _loadBuild(_editingBuildId!);
        }
      }
      _didLoadArguments = true;
    }
  }

  Future<void> _loadBuild(int buildId) async {
    final db = await _localDatabase.database;
    final buildMaps = await db.query(
      'builds',
      where: 'id = ?',
      whereArgs: [buildId],
      limit: 1,
    );
    if (buildMaps.isNotEmpty) {
      final existingBuild = Build.fromMap(buildMaps.first);
      setState(() {
        _makeController.text = existingBuild.make;
        _modelController.text = existingBuild.model;
        _yearController.text = existingBuild.year.toString();
      });
    }
  }

  Future<void> _saveBuild() async {
    if (!_formKey.currentState!.validate()) return;

    final db = await _localDatabase.database;
    final userId = AuthService.instance.currentUser?.id ?? 0;
    final make = _makeController.text;
    final model = _modelController.text;
    final year = int.tryParse(_yearController.text) ?? 0;

    if (_isEdit && _editingBuildId != null) {
      await db.update(
        'builds',
        {
          'year': year,
          'make': make,
          'model': model,
          'userId': userId,
        },
        where: 'id = ?',
        whereArgs: [_editingBuildId],
      );
    } else {
      await db.insert('builds', {
        'year': year,
        'make': make,
        'model': model,
        'userId': userId,
      });
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Build' : 'Create Build'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveBuild,
                child: Text(_isEdit ? 'Update Build' : 'Save Build'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
