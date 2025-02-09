// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/comment/build_comment.dart';
import 'package:pd/utilities/dialogs/manage_dialog.dart';

Future<bool> showManageCommentDialog(
  BuildContext context,
  Map<String, dynamic> comment,
  VoidCallback reloadBuildData,
) async {
  bool success = false;

  await showManageDialog(
    context: context,
    title: 'Manage Comment',
    label: 'Comment',
    initialValue: comment['body'] ?? '',
    itemType: 'comment',
    onDelete: () async {
      success = await deleteComment(context, comment['id']);
      if (success) {
        reloadBuildData();
      }
      return success;
    },
    onUpdate: (updatedComment) async {
      if (updatedComment.trim().isNotEmpty) {
        success = await updateComment(context, comment['id'], updatedComment.trim());
        if (success) {
          reloadBuildData();
        }
      }
    },
  );

  return success;
}
