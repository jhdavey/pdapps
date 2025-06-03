import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pd/services/api/report_user.dart';
import 'package:pd/utilities/dialogs/comments/add_comment_dialog.dart';
import 'package:pd/utilities/dialogs/comments/manage_comment_dialogs.dart';
import 'package:pd/utilities/dialogs/posts/add_post_comment_dialog.dart';
import 'package:pd/utilities/dialogs/posts/manage_post_comment_dialog.dart';

enum CommentType { build, post }

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final List<dynamic> replies;
  final String contextId;
  final String? currentUserId;
  final VoidCallback reloadData;
  final int level;
  final CommentType type;

  const CommentTile({
    super.key,
    required this.comment,
    required this.replies,
    required this.contextId,
    required this.currentUserId,
    required this.reloadData,
    required this.type,
    this.level = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool commentIsOwner = comment['user_id']?.toString() == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(left: 0.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            dense: true,
            onLongPress: () {
              if (!commentIsOwner && comment['user'] != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.grey[900],
                    duration: const Duration(seconds: 5),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            reportUser(comment['user'], context);
                          },
                          child: const Text("Report", style: TextStyle(color: Colors.redAccent)),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            blockUser(comment['user'], context);
                          },
                          child: const Text("Block", style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: (comment['user']?['profile_image']?.isNotEmpty == true &&
                      !(comment['user']['profile_image'] as String).contains("assets/images"))
                  ? NetworkImage(comment['user']['profile_image'])
                  : const AssetImage('assets/images/profile_placeholder.png') as ImageProvider,
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (comment['parent_id'] != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.white70),
                  ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${comment['user']?['name'] ?? 'User ${comment['user_id']}'}\n",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (comment['user']?['id'] != null) {
                                Navigator.pushNamed(context, '/garage', arguments: comment['user']['id']);
                              }
                            },
                        ),
                        TextSpan(
                          text: comment['body'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.reply, color: Colors.white, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    if (type == CommentType.build) {
                      await showAddCommentDialog(
                        context,
                        contextId,
                        reloadData,
                        parentId: comment['id'],
                      );
                    } else {
                      await showAddPostCommentDialog(
                        context,
                        contextId,
                        reloadData,
                        parentId: comment['id'],
                      );
                    }
                  },
                ),
                if (commentIsOwner)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final bool result = (type == CommentType.build)
                          ? await showManageCommentDialog(context, comment, reloadData)
                          : await showManagePostCommentDialog(context, comment, reloadData);

                      if (result == true) {
                        reloadData(); // Only refresh if update/delete was successful
                      }
                    },
                  ),
              ],
            ),
          ),
          ...replies.map(
            (reply) => CommentTile(
              comment: reply,
              replies: reply['replies'] ?? [],
              contextId: contextId,
              currentUserId: currentUserId,
              reloadData: reloadData,
              type: type,
              level: 0,
            ),
          ),
        ],
      ),
    );
  }
}
