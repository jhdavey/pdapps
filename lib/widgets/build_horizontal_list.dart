import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';

Widget buildHorizontalList(List<dynamic> builds) {
  return SizedBox(
    height: 325,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: builds.length,
      itemBuilder: (context, index) {
        final build = builds[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/build-view', arguments: build);
          },
          onLongPress: () {
            // Show a Snackbar with Report and Block actions.
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
                        if (build['user'] != null) {
                          reportUser(build['user'], context);
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
                        if (build['user'] != null) {
                          blockUser(build['user'], context);
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
          child: SizedBox(
            width: 275,
            child: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 2,
                    child: Image.network(
                      build['image'] ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          build['user'] != null && build['user']['name'] != null
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
        );
      },
    ),
  );
}
