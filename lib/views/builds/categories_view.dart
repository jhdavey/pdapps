// categories_view.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriesView extends StatefulWidget {
  final String category;
  const CategoriesView({Key? key, required this.category}) : super(key: key);

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late Future<List<dynamic>> _builds;

  Future<List<dynamic>> _fetchBuildsByCategory() async {
    // Interpolate the category into the URL.
    final String apiUrl =
        'https://passiondrivenbuilds.com/api/categories/${Uri.encodeComponent(widget.category)}';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Assuming the API returns a JSON object with a "builds" key.
      return (data['builds'] ?? []) as List<dynamic>;
    } else {
      throw Exception('Failed to load builds for category ${widget.category}');
    }
  }

  @override
  void initState() {
    super.initState();
    _builds = _fetchBuildsByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Category'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _builds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found for this category.'));
          }
          final builds = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // same as in TagView/HomeView grid
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
                      // Top section: Build image
                      Expanded(
                        flex: 3,
                        child: Image.network(
                          build['image'] ?? 'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      // Bottom section: Build details
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // User's name
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
                              // Build year, make, and model
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
                              // Display build tags using the helper widget.
                              _buildTags(build),
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
        },
      ),
    );
  }

  // Helper widget to display build tags as a horizontal list of clickable chips.
  Widget _buildTags(Map<String, dynamic> build) {
    final List tagList = build['tags'] is List ? build['tags'] : [];
    if (tagList.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tagList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, idx) {
          final tag = tagList[idx];
          return GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              label: Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(fontSize: 10, color: Colors.white, height: 1.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
