import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

Future<void> showManageDialog({
  required BuildContext context,
  required String title,
  required String label,
  required String initialValue,
  required void Function(String) onUpdate,
  required Future<bool> Function() onDelete,
}) async {
  String? updatedText = initialValue;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextFormField(
          initialValue: updatedText,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => updatedText = value,
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFED1C24)),
            onPressed: () async {
              final confirm = await showDeleteDialog(context);
              if (confirm) {
                final success = await onDelete();
                if (success) {
                  Navigator.pop(context); // Close Manage Dialog
                }
              }
            },
          ),

          // Update Button
          ElevatedButton(
            onPressed: () {
              if (updatedText != null && updatedText!.trim().isNotEmpty) {
                onUpdate(updatedText!.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );
}
