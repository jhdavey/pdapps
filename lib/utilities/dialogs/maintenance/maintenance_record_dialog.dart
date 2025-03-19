// maintenance_record_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/maintenance/edit_maintenance_record_dialog.dart';
import 'create_maintenance_record_dialog.dart';
import 'package:pd/services/api/maintenance_controller.dart';

/// Opens the maintenance records dialog.
/// Pass `isOwner: true` if the current user is the build owner.
void showMaintenanceRecordsDialog(
    BuildContext context, int buildId, {bool isOwner = false}) {
  showDialog(
    context: context,
    builder: (context) =>
        _MaintenanceRecordsDialog(buildId: buildId, isOwner: isOwner),
  );
}

class _MaintenanceRecordsDialog extends StatefulWidget {
  final int buildId;
  final bool isOwner;
  const _MaintenanceRecordsDialog(
      {Key? key, required this.buildId, required this.isOwner})
      : super(key: key);

  @override
  State<_MaintenanceRecordsDialog> createState() =>
      _MaintenanceRecordsDialogState();
}

class _MaintenanceRecordsDialogState extends State<_MaintenanceRecordsDialog> {
  late Future<List<dynamic>?> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    _recordsFuture = MaintenanceRecordService(baseUrl: "https://passiondrivenbuilds.com/api")
        .fetchMaintenanceRecords(context, buildId: widget.buildId);
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to ensure isOwner is set correctly.
    print("MaintenanceRecordsDialog isOwner: ${widget.isOwner}");

    return AlertDialog(
      backgroundColor: const Color(0xFF1F242D),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Maintenance Records",
            style: TextStyle(color: Colors.white),
          ),
          if (widget.isOwner)
            // Plus icon for adding a new maintenance record.
            IconButton(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              onPressed: () async {
                final result = await showDialog<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => const MaintenanceRecordFormDialog(),
                );
                if (result != null) {
                  final success = await MaintenanceRecordService(
                          baseUrl: "https://passiondrivenbuilds.com/api")
                      .createMaintenanceRecord(
                    context,
                    buildId: widget.buildId,
                    date: result['date'] != null
                        ? DateTime.parse(result['date'])
                        : null,
                    description: result['description'],
                    odometer: result['odometer'],
                    servicedBy: result['servicedBy'],
                    cost: result['cost'],
                  );
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Record added successfully.")),
                    );
                    setState(() {
                      _loadRecords();
                    });
                  }
                }
              },
              tooltip: "Add Maintenance Record",
            ),
        ],
      ),
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: FutureBuilder<List<dynamic>?>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Error loading records.",
                    style: TextStyle(color: Colors.white)),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No maintenance records found.",
                    style: TextStyle(color: Colors.white70)),
              );
            } else {
              final records = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                itemCount: records.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: Colors.white70),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final dynamic idValue = record['id'];
                  if (idValue == null ||
                      idValue.toString().trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final int? recordId = int.tryParse(idValue.toString());
                  if (recordId == null) return const SizedBox.shrink();

                  return ListTile(
                    title: Text(
                      record['description'] ?? "No description",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (record['date'] != null &&
                            record['date'].toString().trim().isNotEmpty)
                          Text(
                            "Date: ${record['date']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (record['odometer'] != null &&
                            record['odometer'].toString().trim().isNotEmpty)
                          Text(
                            "Odometer: ${record['odometer']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (record['serviced_by'] != null &&
                            record['serviced_by'].toString().trim().isNotEmpty)
                          Text(
                            "Serviced by: ${record['serviced_by']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        if (record['cost'] != null &&
                            record['cost'].toString().trim().isNotEmpty)
                          Text(
                            "Cost: \$${record['cost']}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                    trailing: widget.isOwner
                        ? IconButton(
                            icon: const Icon(Icons.edit,
                                size: 16, color: Colors.white),
                            onPressed: () async {
                              final result =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (context) =>
                                    EditMaintenanceRecordFormDialog(
                                  buildId: widget.buildId,
                                  initialData: record,
                                ),
                              );
                              if (result != null) {
                                if (result.containsKey('action') &&
                                    result['action'] == 'delete') {
                                  setState(() {
                                    _loadRecords();
                                  });
                                } else {
                                  final success =
                                      await MaintenanceRecordService(
                                    baseUrl:
                                        "https://passiondrivenbuilds.com/api",
                                  ).updateMaintenanceRecord(
                                    context,
                                    buildId: widget.buildId,
                                    recordId: recordId,
                                    date: result['date'] != null
                                        ? DateTime.parse(result['date'])
                                        : null,
                                    description: result['description'],
                                    odometer: result['odometer'],
                                    servicedBy: result['servicedBy'],
                                    cost: result['cost'],
                                  );
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Record updated successfully.")),
                                    );
                                    setState(() {
                                      _loadRecords();
                                    });
                                  }
                                }
                              }
                            },
                            tooltip: "Edit Record",
                          )
                        : null,
                  );
                },
              );
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child:
              const Text("Close", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
