import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';

Widget buildHorizontalList(List<dynamic> builds) {
  return SizedBox(
    height: 325,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: builds.length,
      itemBuilder: (context, index) {
        final build = builds[index];
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/build-view', arguments: build);
            },
            child: SizedBox(
              width: 275, // Doubled the width from 150 to 300
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Use AspectRatio to maintain the image's aspect ratio.
                    AspectRatio(
                      aspectRatio: 3 / 2, // Adjust the ratio as needed
                      child: Image.network(
                        build['image'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            build['user'] != null &&
                                    build['user']['name'] != null
                                ? "${build['user']['name']}'s"
                                : 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${build['build_category']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${build['year']} ${build['make']} ${build['model']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: TagChipList(
                              tags: build['tags'] is List ? build['tags'] : [],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
