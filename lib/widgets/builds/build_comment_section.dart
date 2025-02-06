// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/helpers/format_datetime_string.dart';
import 'package:pd/utilities/dialogs/add_comment_dialog.dart';
import 'package:pd/utilities/dialogs/manage_commnet_dialogs.dart';

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
        color: Color(0xFF1F242C),
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
                              final result = await showManageCommentDialog(
                                  context, comment, reloadBuildData);
                              if (result == true) {
                                reloadBuildData();
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
