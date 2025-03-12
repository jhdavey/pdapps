import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';

class BuildCard extends StatelessWidget {
  final Map<String, dynamic> buildData;

  const BuildCard({Key? key, required this.buildData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if there are tags.
    final bool hasTags = buildData['tags'] is List && (buildData['tags'] as List).isNotEmpty;

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
            // The image will fill more space if there are no tags.
            Expanded(
              flex: hasTags ? 2 : 3,
              child: Image.network(
                buildData['image'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
              ),
            ),
            // Information section.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: user info, year/make/model, and (if available) tags.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          buildData['user'] != null && buildData['user']['name'] != null
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
                        if (hasTags) ...[
                          const SizedBox(height: 4),
                          TagChipList(
                            tags: buildData['tags'] is List ? buildData['tags'] : [],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Right column: Build category.
                  Text(
                    buildData['build_category'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
