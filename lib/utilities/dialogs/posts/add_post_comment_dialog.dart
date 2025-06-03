// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/post/post_comment.dart';
import 'package:pd/utilities/dialogs/create_dialog.dart';

Future<void> showAddPostCommentDialog(
  BuildContext context,
  String postId,
  VoidCallback reloadPostData, {
  int? parentId,
}) async {
  await showCreateDialog(
    context: context,
    title: 'Add Comment',
    label: 'Comment',
    onSubmit: (commentBody) async {
      final success = await postCommentOnPost(
        context,
        postId,
        commentBody,
        parentId: parentId,
      );
      if (success) {
        reloadPostData();
      }
    },
  );
}
