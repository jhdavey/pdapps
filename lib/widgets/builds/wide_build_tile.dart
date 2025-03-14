// *** CURRENTLY UNUSED ***
import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';

class WideBuildTile extends StatelessWidget {
  final Map<String, dynamic> buildData;
  final Map<String, dynamic> user;
  final bool isOwner;

  const WideBuildTile({
    super.key,
    required this.buildData,
    required this.user,
    required this.isOwner,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> buildWithUser = {
      ...buildData,
      'user': user,
    };

    final String? imageUrl = buildData['image'];
    final ImageProvider imageProvider =
        (imageUrl != null && imageUrl.isNotEmpty)
            ? NetworkImage(imageUrl)
            : const AssetImage('assets/images/placeholder_car_image.png');

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed('/build-view', arguments: buildWithUser);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Text(
                        buildData['build_category'] ?? 'Unknown Category',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${buildData['year']} ${buildData['make']} ${buildData['model']}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "HP: ${buildData['hp'] ?? 'N/A'}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Torque: ${buildData['torque'] ?? 'N/A'}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TagChipList(
                      tags: buildData['tags'] is List ? buildData['tags'] : [],
                    ),
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
