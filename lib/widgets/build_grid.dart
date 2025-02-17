import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';

Widget buildGrid(List<dynamic> builds, int columns) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
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
        onLongPress: () {
          // Show a Snackbar with both Report and Block actions.
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
                    TagChipList(
                      tags: build['tags'] is List ? build['tags'] : [],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
