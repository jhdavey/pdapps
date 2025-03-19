import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pd/services/api/report_user.dart';
import 'package:pd/utilities/dialogs/comments/add_comment_dialog.dart';
import 'package:pd/utilities/dialogs/comments/manage_comment_dialogs.dart';

class CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final List<dynamic> replies;
  final String buildId;
  final String? currentUserId;
  final VoidCallback reloadBuildData;
  // The level parameter is retained for potential styling, but will not affect horizontal alignment.
  final int level;

  const CommentTile({
    Key? key,
    required this.comment,
    required this.replies,
    required this.buildId,
    required this.currentUserId,
    required this.reloadBuildData,
    this.level = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool commentIsOwner = comment['user_id'] != null &&
        comment['user_id'].toString() == currentUserId?.toString();

    // No extra horizontal indentation.
    const double indent = 0.0;

    return Padding(
      padding: const EdgeInsets.only(left: indent, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            dense: true,
            // Re-add reporting functionality on long press:
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
                          child: const Text(
                            "Report",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            blockUser(comment['user'], context);
                          },
                          child: const Text(
                            "Block",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: (comment['user'] != null &&
                      comment['user']['profile_image'] != null &&
                      (comment['user']['profile_image'] as String).isNotEmpty &&
                      !(comment['user']['profile_image'] as String)
                          .contains("assets/images"))
                  ? NetworkImage(comment['user']['profile_image'])
                  : const AssetImage('assets/images/profile_placeholder.png'),
            ),

            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // If this is a reply, display a small indicator icon.
                if (comment['parent_id'] != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.subdirectory_arrow_right,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${comment['user'] != null ? comment['user']['name'] : 'User ${comment['user_id']}'}\n",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            height: 1.5,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (comment['user'] != null &&
                                  comment['user']['id'] != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/garage',
                                  arguments: comment['user']['id'],
                                );
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
                    await showAddCommentDialog(
                      context,
                      buildId,
                      reloadBuildData,
                      parentId: comment['id'],
                    );
                  },
                ),
                if (commentIsOwner)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      final result = await showManageCommentDialog(
                        context,
                        comment,
                        reloadBuildData,
                      );
                      if (result == true) {
                        reloadBuildData();
                      }
                    },
                  ),
              ],
            ),
          ),
          // Render nested replies recursively.
          ...replies.map(
            (reply) => CommentTile(
              comment: reply,
              replies: reply['replies'] ?? [],
              buildId: buildId,
              currentUserId: currentUserId,
              reloadBuildData: reloadBuildData,
              level: 0, // All nested replies use level 0 for alignment.
            ),
          ),
        ],
      ),
    );
  }
}
