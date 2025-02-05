// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/helpers/format_datetime_string.dart';
import 'package:pd/services/api/build/comment/build_comment.dart';
import 'package:pd/utilities/dialogs/build_comment_dialogs.dart';

class BuildCommentsSection extends StatelessWidget {
  final List<dynamic> comments;
  final String buildId;
  final String? currentUserId;
  final VoidCallback reloadBuildData;

  const BuildCommentsSection({
    super.key,
    required this.comments,
    required this.buildId,
    required this.currentUserId,
    required this.reloadBuildData,
  });

  @override
  Widget build(BuildContext context) {
    final List<dynamic> reversedComments = List.from(comments.reversed);

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Comments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  await showAddCommentDialog(context, buildId, reloadBuildData);
                },
              ),
            ],
          ),
          if (reversedComments.isEmpty)
            const Text(
              'No comments have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...reversedComments.map((comment) {
              final bool commentIsOwner = comment['user_id'] != null &&
                  comment['user_id'].toString() == currentUserId?.toString();

              return ListTile(
                title: Text(
                  comment['body'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  "${comment['user'] != null ? comment['user']['name'] : 'User ${comment['user_id']}'} • ${formatDateTime(comment['created_at'] ?? '')}",
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: commentIsOwner
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () async {
                              final result = await showEditCommentDialog(context, comment, reloadBuildData);
                              if (result == true) {
                                reloadBuildData();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Comment'),
                                  content: const Text('Are you sure you want to delete this comment?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete'),
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
                        ],
                      )
                    : null,
              );
            })
        ],
      ),
    );
  }
}
