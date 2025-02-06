// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/build/comment/build_comment.dart';

Future<bool> showManageCommentDialog(
  BuildContext context,
  Map<String, dynamic> comment,
  VoidCallback reloadBuildData,
) async {
  String? updatedComment = comment['body'];

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Manage Comment'),
        content: TextFormField(
          initialValue: updatedComment,
          decoration: const InputDecoration(
            labelText: 'Comment',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => updatedComment = value,
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFED1C24)),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Comment'),
                  content: const Text(
                      'Are you sure you want to delete this comment?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Color(0xFFED1C24)),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final success = await deleteComment(context, comment['id']);
                if (success) {
                  reloadBuildData();
                }
              }
            },
          ),

          // Update button
          ElevatedButton(
            onPressed: () async {
              if (updatedComment != null && updatedComment!.trim().isNotEmpty) {
                final success = await updateComment(
                  context,
                  comment['id'],
                  updatedComment!.trim(),
                );
                Navigator.pop(context, success);
              }
            },
            child: const Text('Update'),
          ),
        ],
      );
    },
  );

  if (result == true) {
    reloadBuildData();
  }
  return result ?? false;
}
