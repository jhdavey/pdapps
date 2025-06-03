// lib/widgets/builds/build_comment_section.dart
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

  // Convert flat list into a nested tree
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

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.hardEdge,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            // Use the same collapsedBackgroundColor as “Build Sheet”
            collapsedBackgroundColor: Theme.of(context).cardTheme.color,
            backgroundColor: Colors.transparent,
            iconColor: Colors.white,
            collapsedIconColor: Colors.white,
            tilePadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
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
              const SizedBox(height: 8),
              if (topLevelComments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'No comments have been added yet.',
                    style: TextStyle(color: Colors.white70),
                  ),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
