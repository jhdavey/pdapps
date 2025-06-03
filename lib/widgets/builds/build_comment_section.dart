// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/comments/add_comment_dialog.dart';
import 'package:pd/widgets/comment_tile.dart';

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

  // Build a nested tree structure from the flat list of comments.
  List<Map<String, dynamic>> buildCommentTree(List<dynamic> comments) {
    final Map<int, Map<String, dynamic>> commentMap = {};
    for (var comment in comments) {
      comment['replies'] = [];
      commentMap[comment['id']] = comment;
    }

    final List<Map<String, dynamic>> tree = [];
    for (var comment in comments) {
      if (comment['parent_id'] == null) {
        tree.add(comment);
      } else {
        if (commentMap.containsKey(comment['parent_id'])) {
          commentMap[comment['parent_id']]!['replies'].add(comment);
        } else {
          tree.add(comment);
        }
      }
    }
    return tree;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> commentTree = buildCommentTree(comments);
    final topLevelComments = commentTree.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // ↓ EXACTLY THE SAME PADDING / COLORS as Notes and Modifications ↓
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 6.0),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 6.0),

          title: Row(
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
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await showAddCommentDialog(
                    context,
                    buildId,
                    reloadBuildData,
                  );
                },
              ),
            ],
          ),

          children: [
            const SizedBox(height: 10),

            if (topLevelComments.isEmpty)
              const Text(
                'No comments have been added yet.',
                style: TextStyle(color: Colors.white70),
              )
            else
              ...topLevelComments.map((comment) {
                return CommentTile(
                  comment: comment,
                  replies: comment['replies'] as List<dynamic>,
                  buildId: buildId,
                  currentUserId: currentUserId,
                  reloadBuildData: reloadBuildData,
                );
              }).toList(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
