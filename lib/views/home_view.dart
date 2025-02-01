// home_view.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pd/services/api/auth_service.dart';
import 'package:pd/widgets/custom_scaffold.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<Map<String, dynamic>> _buildData;

  // Fetch build data from the API
  Future<Map<String, dynamic>> _fetchBuildData() async {
    const String apiUrl = 'https://passiondrivenbuilds.com/api/builds';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load builds');
    }
  }

  @override
  void initState() {
    super.initState();
    _buildData = _fetchBuildData();
  }

  @override
  Widget build(BuildContext context) {
    // Use RepositoryProvider to access ApiAuthService
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    authService.getCurrentUser().then((user) {
      // Optionally, use user info if needed.
    });

    return CustomScaffold(
      title: 'Passion Driven Builds',
      body: FutureBuilder<Map<String, dynamic>>(
        future: _buildData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found.'));
          }

          final data = snapshot.data!;
          final featuredBuilds = data['featuredBuilds'] as List<dynamic>? ?? [];
          final builds = data['builds'] as List<dynamic>? ?? [];
          final followingBuilds = data['followingBuilds'] as List<dynamic>? ?? [];
          final categories = data['categories'] as List<dynamic>? ?? [];
          final tags = data['tags'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Builds
                  if (featuredBuilds.isNotEmpty) ...[
                    const Text(
                      'Featured Builds',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildGrid(featuredBuilds, 3),
                  ],
                  const Divider(),

                  // Following Builds
                  const Text(
                    'Following',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (followingBuilds.isEmpty)
                    const Text('You are not following any builds yet.')
                  else
                    _buildGrid(followingBuilds, 3),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Browse by Categories
                  const Text(
                    'Browse by Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      return Chip(
                        label: Text(category['build_category'] ?? 'Unknown'),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Browse by Tags (Horizontal Scroll)
                  const Text(
                    'Browse by Tags',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40, // Fixed height for horizontal tag chips
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/tag-view',
                                arguments: {'tag': tag},
                              );
                            },
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.blueGrey,
                              label: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  tag['name'] ?? 'Tag',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Browse Builds
                  const Text(
                    'Recently Updated',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildGrid(builds, 3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper function to build grid view for builds.
  Widget _buildGrid(List<dynamic> builds, int columns) {
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
  }

  // Helper widget to display build tags as a horizontal list of chips.
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
              Navigator.of(context).pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              backgroundColor: Colors.blueGrey,
              label: Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
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
