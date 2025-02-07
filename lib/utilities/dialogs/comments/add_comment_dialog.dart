// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/build/comment/build_comment.dart';
import 'package:pd/utilities/dialogs/create_dialog.dart';

Future<void> showAddCommentDialog(
  BuildContext context,
  String buildId,
  VoidCallback reloadBuildData,
) async {
  await showCreateDialog(
    context: context,
    title: 'Add Comment',
    label: 'Comment',
    onSubmit: (commentBody) async {
      final success = await postComment(context, buildId, commentBody);
      if (success) {
        reloadBuildData();
      }
    },
  );
}
