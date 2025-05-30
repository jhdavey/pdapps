import 'package:flutter/material.dart';

Future<String?> showSearchDialog(BuildContext context) {
  String? searchQuery;

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Search Builds'),
        content: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Enter search query',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => searchQuery = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final trimmed = searchQuery?.trim();
              Navigator.of(context).pop(
                (trimmed != null && trimmed.isNotEmpty) ? trimmed : null,
              );
            },
            child: const Text('Search'),
          ),
        ],
      );
    },
  );
}