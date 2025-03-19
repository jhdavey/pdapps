// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pd/services/api/maintenance_controller.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class EditMaintenanceRecordFormDialog extends StatefulWidget {
  final int buildId;
  final Map<String, dynamic> initialData;

  const EditMaintenanceRecordFormDialog({
    super.key,
    required this.buildId,
    required this.initialData,
  });

  @override
  _EditMaintenanceRecordFormDialogState createState() =>
      _EditMaintenanceRecordFormDialogState();
}

class _EditMaintenanceRecordFormDialogState
    extends State<EditMaintenanceRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  late String _description;
  late String _odometer;
  late String _servicedBy;
  late String _cost;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _date = data['date'] != null ? DateTime.tryParse(data['date']) : null;
    _description = data['description'] ?? "";
    _odometer = data['odometer'] ?? "";
    _servicedBy = data['serviced_by'] ?? "";
    _cost = data['cost']?.toString() ?? "";
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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

  Future<void> _deleteRecord() async {
    final confirm = await showDeleteDialog(context, "maintenance record");
    if (confirm) {
      final dynamic idValue = widget.initialData['id'];
      if (idValue == null || idValue.toString().trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid record ID.")));
        return;
      }
      final int? recordId = int.tryParse(idValue.toString());
      if (recordId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid record ID.")));
        return;
      }
      final success = await MaintenanceRecordService(
              baseUrl: "https://passiondrivenbuilds.com/api")
          .deleteMaintenanceRecord(
              context, buildId: widget.buildId, recordId: recordId);
      if (success) {
        Navigator.of(context).pop({'action': 'delete'});
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedCost = (_cost.trim().isEmpty) ? null : _cost;
      final updatedOdometer = (_odometer.trim().isEmpty) ? null : _odometer;
      final updatedServicedBy = (_servicedBy.trim().isEmpty) ? null : _servicedBy;
      Navigator.of(context).pop({
        'date': _date?.toIso8601String(),
        'description': _description,
        'odometer': updatedOdometer,
        'servicedBy': updatedServicedBy,
        'cost': updatedCost,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1F242D),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Edit Maintenance Record",
            style: TextStyle(color: Colors.white),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
            onPressed: _deleteRecord,
            tooltip: "Delete Record",
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date (optional)
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date (optional)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                controller: TextEditingController(
                  text: _date != null ? "${_date!.toLocal()}".split(' ')[0] : "",
                ),
              ),
              const SizedBox(height: 10),
              // Description (required)
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: "Description *"),
                validator: (value) =>
                    (value == null || value.isEmpty) ? "Description is required" : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 10),
              // Odometer (optional)
              TextFormField(
                initialValue: _odometer,
                decoration: const InputDecoration(labelText: "Odometer (optional)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => _odometer = value ?? "",
              ),
              const SizedBox(height: 10),
              // Serviced by (optional)
              TextFormField(
                initialValue: _servicedBy,
                decoration: const InputDecoration(labelText: "Serviced by (optional)"),
                onSaved: (value) => _servicedBy = value ?? "",
              ),
              const SizedBox(height: 10),
              // Cost (optional)
              TextFormField(
                initialValue: _cost,
                decoration: const InputDecoration(labelText: "Cost (optional)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => _cost = value ?? "",
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
