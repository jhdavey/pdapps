import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pd/widgets/posts/comments_snackbar.dart';
import 'package:pd/widgets/posts/like_button.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';
import 'package:pd/services/api/post/post_controller.dart';
import 'package:pd/utilities/dialogs/posts/post_dialog.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;
  final String? currentUserId;
  final VoidCallback? onPostUpdatedOrDeleted;

  const PostCard({
    super.key,
    required this.postData,
    required this.currentUserId,
    this.onPostUpdatedOrDeleted,
  });

  String _formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return "${dateTime.month}/${dateTime.day}/${dateTime.year}";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTags =
        postData['tags'] is List && (postData['tags'] as List).isNotEmpty;
    final bool isOwner = currentUserId != null &&
        postData['user']?['id'].toString() == currentUserId;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/post-view', arguments: postData);
      },
      onLongPress: () {
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
                    if (postData['user'] != null) {
                      reportUser(postData['user'], context);
                    }
                  },
                  child: const Text(
                    "Report",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (postData['user'] != null) {
                      blockUser(postData['user'], context);
                    }
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
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Media (image/video) at top
            AspectRatio(
              aspectRatio: 3 / 2,
              child: (postData['media_path'] != null &&
                      postData['media_path'].toString().isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: postData['media_path'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.asset(
                      'assets/images/placeholder_car_image.png',
                      fit: BoxFit.cover,
                    ),
            ),

            // 2) Username + caption + tags
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${postData['year'] ?? ''} ${postData['make'] ?? ''} ${postData['model'] ?? ''}'
                                  .trim(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              LikeButton(
                                postId: postData['id'],
                                initialIsLiked: postData['is_liked'] ?? false,
                                initialLikeCount: postData['like_count'] ?? 0,
                              ),
                              IconButton(
                                icon: const Icon(Icons.comment,
                                    size: 20, color: Colors.white70),
                                onPressed: () async {
                                  final comments = await PostService()
                                      .getPostComments(postData['id']);
                                  if (context.mounted) {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (ctx) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: PostCommentsSnackbar(
                                          comments: comments,
                                          postId: postData['id'],
                                          currentUserId: currentUserId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              if (isOwner) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Color.fromARGB(255, 16, 2, 2), size: 20),
                                  onPressed: () async {
                                    final updated = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => PostDialog(
                                        buildId: postData['build_id'],
                                        existingPostData: postData,
                                        reloadBuildData: () async {},
                                      ),
                                    );
                                    if (updated == true) {
                                      onPostUpdatedOrDeleted?.call();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Post updated.')),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Post'),
                                        content: const Text(
                                            'Are you sure you want to delete this post?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await PostService()
                                          .deletePost(postId: postData['id']);
                                      onPostUpdatedOrDeleted?.call();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('Post deleted.')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (postData['caption'] != null &&
                          postData['caption'].toString().isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: (postData['user']?['name'] ??
                                            'Unknown User') +
                                        ': ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  TextSpan(
                                    text: postData['caption'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (postData['updated_at'] != null)
                              Text(
                                'Last updated: ${_formatDate(postData['updated_at'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      if (hasTags)
                        SizedBox(
                          width: availableWidth,
                          child: TagChipList(
                            tags: postData['tags'] as List<dynamic>,
                            alignment: MainAxisAlignment.start,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
