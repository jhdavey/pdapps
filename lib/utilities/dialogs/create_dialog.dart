import 'package:flutter/material.dart';

Future<void> showCreateDialog({
  required BuildContext context,
  required String title,
  required String label,
  required void Function(String) onSubmit,
}) async {
  String? inputText;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => inputText = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (inputText != null && inputText!.trim().isNotEmpty) {
                onSubmit(inputText!.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    },
  );
}
