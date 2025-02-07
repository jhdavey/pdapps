// ignore_for_file: use_build_context_synchronously
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/comments/add_comment_dialog.dart';
import 'package:pd/utilities/dialogs/comments/manage_comment_dialogs.dart';

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
        color: const Color(0xFF1F242C),
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
  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
  dense: true,
  title: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 20,
        backgroundImage: comment['user'] != null &&
                comment['user']['profile_image'] != null &&
                comment['user']['profile_image'].isNotEmpty
            ? NetworkImage(comment['user']['profile_image'])
            : const AssetImage('assets/images/profile_placeholder.png')
                as ImageProvider,
      ),
      const SizedBox(width: 8),
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
                    if (comment['user'] != null && comment['user']['id'] != null) {
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
        ),
      ),
      if (commentIsOwner)
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () async {
            final result = await showManageCommentDialog(
                context, comment, reloadBuildData);
            if (result == true) {
              reloadBuildData();
            }
          },
        ),
    ],
  ),
);

            })
        ],
      ),
    );
  }
}
