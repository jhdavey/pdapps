// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class MaintenanceRecordFormDialog extends StatefulWidget {
  const MaintenanceRecordFormDialog({super.key});

  @override
  _MaintenanceRecordFormDialogState createState() =>
      _MaintenanceRecordFormDialogState();
}

class _MaintenanceRecordFormDialogState
    extends State<MaintenanceRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  String? _description;
  String? _odometer;
  String? _servicedBy;
  String? _cost;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // Return the new record data to the caller.
      Navigator.of(context).pop({
        'date': _date?.toIso8601String(),
        'description': _description,
        'odometer': _odometer,
        'servicedBy': _servicedBy,
        'cost': _cost,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Maintenance Record"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date (optional) with date picker.
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date (optional)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                controller: TextEditingController(
                  text: _date != null ? "${_date!.toLocal()}".split(' ')[0] : '',
                ),
              ),
              const SizedBox(height: 10),
              // Description (required)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description *',
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Description is required'
                    : null,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 10),
              // Odometer (optional)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Odometer (optional)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _odometer = value,
              ),
              const SizedBox(height: 10),
              // Serviced by (optional)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Serviced by (optional)',
                ),
                onSaved: (value) => _servicedBy = value,
              ),
              const SizedBox(height: 10),
              // Cost (optional)
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cost (optional)',
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cost = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
