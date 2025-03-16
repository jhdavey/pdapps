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
    // Create a map of comment id to comment object.
    final Map<int, Map<String, dynamic>> commentMap = {};
    for (var comment in comments) {
      // Ensure each comment has a 'replies' key.
      comment['replies'] = [];
      commentMap[comment['id']] = comment;
    }
    
    // List for top-level comments.
    final List<Map<String, dynamic>> tree = [];
    
    for (var comment in comments) {
      if (comment['parent_id'] == null) {
        tree.add(comment);
      } else {
        // Add the comment to its parent's 'replies' list if the parent exists.
        if (commentMap.containsKey(comment['parent_id'])) {
          commentMap[comment['parent_id']]!['replies'].add(comment);
        } else {
          // If parent not found, treat it as top-level (optional fallback)
          tree.add(comment);
        }
      }
    }
    return tree;
  }

  @override
  Widget build(BuildContext context) {
    // Build the tree from the flat comments list.
    final List<Map<String, dynamic>> commentTree = buildCommentTree(comments);
    
    // Optionally, reverse the order of top-level comments if desired.
    final topLevelComments = commentTree.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and add button.
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
          // Display a friendly message if there are no comments.
          if (topLevelComments.isEmpty)
            const Text(
              'No comments have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            // Render each top-level comment using CommentTile.
            ...topLevelComments.map((comment) => CommentTile(
                  comment: comment,
                  replies: comment['replies'] as List<dynamic>,
                  buildId: buildId,
                  currentUserId: currentUserId,
                  reloadBuildData: reloadBuildData,
                )),
        ],
      ),
    );
  }
}
