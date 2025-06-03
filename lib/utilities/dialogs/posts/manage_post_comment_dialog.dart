// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/post/post_comment.dart';
import 'package:pd/utilities/dialogs/manage_dialog.dart';

Future<bool> showManagePostCommentDialog(
  BuildContext context,
  Map<String, dynamic> comment,
  VoidCallback reloadPostData,
) async {
  bool success = false;

  await showManageDialog(
    context: context,
    title: 'Manage Comment',
    label: 'Comment',
    initialValue: comment['body'] ?? '',
    itemType: 'comment',
    onDelete: () async {
      success = await deletePostComment(context, comment['id']);
      if (success) {
        reloadPostData();
      }
      return success;
    },
    onUpdate: (updatedComment) async {
      if (updatedComment.trim().isNotEmpty) {
        success = await updatePostComment(context, comment['id'], updatedComment.trim());
        if (success) {
          reloadPostData();
        }
      }
    },
  );

  return success;
}
