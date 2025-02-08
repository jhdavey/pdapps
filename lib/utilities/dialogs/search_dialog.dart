import 'package:flutter/material.dart';

Future<void> showSearchDialog(BuildContext context) async {
  String? searchQuery;

  await showDialog(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/search-results', arguments: searchQuery);
              }
            },
            child: const Text('Search'),
          ),
        ],
      );
    },
  );
}
