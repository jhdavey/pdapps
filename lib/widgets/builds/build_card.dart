import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';
import 'package:pd/widgets/favorite_button.dart';

class BuildCard extends StatelessWidget {
  final Map<String, dynamic> buildData;

  const BuildCard({Key? key, required this.buildData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasTags =
        buildData['tags'] is List && (buildData['tags'] as List).isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/build-view', arguments: buildData);
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
                    if (buildData['user'] != null) {
                      reportUser(buildData['user'], context);
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
                    if (buildData['user'] != null) {
                      blockUser(buildData['user'], context);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: (buildData['image'] != null &&
                      buildData['image'].toString().isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: buildData['image'],
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
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: user info, build details, and build category.
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buildData['user'] != null &&
                                      buildData['user']['name'] != null
                                  ? "${buildData['user']['name']}'s"
                                  : 'Unknown User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${buildData['year']} ${buildData['make']} ${buildData['model']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 18,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              buildData['build_category'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Right column: Favorite button on top and TagChipList below.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FavoriteButton(
                            buildId: buildData['id'],
                            initialFavoriteCount:
                                buildData['favorite_count'] ?? 0,
                            initialIsFavorited:
                                buildData['is_favorited'] ?? false,
                          ),
                          const SizedBox(height: 8),
                          if (hasTags)
                            Container(
                              // Limit the tag chip list container to 40% of the available width.
                              width: availableWidth * 0.4,
                              child: TagChipList(
                                tags: buildData['tags'] is List
                                    ? buildData['tags']
                                    : [],
                                alignment: MainAxisAlignment.end,
                              ),
                            ),
                        ],
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
