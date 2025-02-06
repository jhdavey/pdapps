// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/build/comment/build_comment.dart';

Future<void> showAddCommentDialog(
  BuildContext context,
  String buildId,
  VoidCallback reloadBuildData,
) async {
  String? commentBody;
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Comment'),
        content: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Comment',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) => commentBody = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (commentBody != null && commentBody!.trim().isNotEmpty) {
                final success =
                    await postComment(context, buildId, commentBody!.trim());
                Navigator.pop(context, success);
              }
            },
            child: const Text('Post'),
          ),
        ],
      );
    },
  );
  reloadBuildData();
}