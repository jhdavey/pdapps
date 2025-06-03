import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;

  const PostCard({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    final bool hasTags =
        postData['tags'] is List && (postData['tags'] as List).isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Navigate to a detailed post view, if you have one:
        Navigator.of(context)
            .pushNamed('/post-view', arguments: postData);
      },
      onLongPress: () {
        // Long‐press options: report or block user.
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
            borderRadius: BorderRadius.circular(10)),
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
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Author’s name
                      Text(
                        postData['user'] != null &&
                                postData['user']['name'] != null
                            ? postData['user']['name']
                            : 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Caption
                      if (postData['caption'] != null &&
                          postData['caption'].toString().isNotEmpty)
                        Text(
                          postData['caption'],
                          style: const TextStyle(fontSize: 16),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const SizedBox(height: 6),

                      // Tags, if any
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
