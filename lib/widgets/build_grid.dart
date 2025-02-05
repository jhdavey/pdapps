import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';

Widget buildGrid(List<dynamic> builds, int columns) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 3 / 4,
    ),
    itemCount: builds.length,
    itemBuilder: (context, index) {
      final build = builds[index];
      if (build is! Map<String, dynamic>) {
        return const Center(child: Text('Invalid build data.'));
      }
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/build-view', arguments: build);
        },
        child: Card(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Image.network(
                  build['image'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        build['user'] != null && build['user']['name'] != null
                            ? "${build['user']['name']}'s"
                            : 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${build['year']} ${build['make']} ${build['model']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      TagChipList(
                        tags: build['tags'] is List ? build['tags'] : [],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
