import 'package:flutter/material.dart';
import 'package:pd/services/api/post/post_controller.dart';
import 'package:pd/utilities/dialogs/posts/add_post_comment_dialog.dart';
import 'package:pd/widgets/comment_tile.dart';

class PostCommentsSnackbar extends StatefulWidget {
  final List<dynamic> comments;
  final int postId;
  final String? currentUserId;

  const PostCommentsSnackbar({
    super.key,
    required this.comments,
    required this.postId,
    required this.currentUserId,
  });

  @override
  State<PostCommentsSnackbar> createState() => _PostCommentsSnackbarState();
}

class _PostCommentsSnackbarState extends State<PostCommentsSnackbar> {
  late List<dynamic> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
  }

  Future<void> _refreshComments() async {
    final updatedComments = await PostService().getPostComments(widget.postId);


    if (mounted) {
      setState(() {
        _comments = updatedComments;
      });
    }
  }

  List<Map<String, dynamic>> _buildCommentTree(List<dynamic> comments) {
    final Map<int, Map<String, dynamic>> commentMap = {};
    for (var comment in comments) {
      comment['replies'] = [];
      commentMap[comment['id']] = comment;
    }

    final List<Map<String, dynamic>> tree = [];
    for (var comment in comments) {
      if (comment['parent_id'] == null) {
        tree.add(comment);
      } else if (commentMap.containsKey(comment['parent_id'])) {
        commentMap[comment['parent_id']]!['replies'].add(comment);
      } else {
        tree.add(comment);
      }
    }
    return tree;
  }

  @override
  Widget build(BuildContext context) {
    final commentTree = _buildCommentTree(_comments);
    final topLevelComments = commentTree.reversed.toList();

    return Container(
      padding: const EdgeInsets.all(8),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: topLevelComments.isEmpty
                ? const Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    thickness: 3,
                    child: ListView(
                      children: topLevelComments.map((comment) {
                        return CommentTile(
                          comment: comment,
                          replies: comment['replies'] as List<dynamic>,
                          contextId: widget.postId.toString(),
                          currentUserId: widget.currentUserId,
                          reloadData: _refreshComments,
                          type: CommentType.post,
                        );
                      }).toList(),
                    ),
                  ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await showAddPostCommentDialog(
                context,
                widget.postId.toString(),
                _refreshComments,
              );
            },
            icon: const Icon(Icons.add_comment),
            label: const Text('Add Comment'),
          ),
        ],
      ),
    );
  }
}
