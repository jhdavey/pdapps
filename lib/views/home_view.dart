// home_view.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pd/services/api/auth_service.dart';
import 'package:pd/widgets/build_grid.dart';
import 'package:pd/widgets/custom_scaffold.dart';
import 'package:pd/data/build_categories.dart';

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

    // Retrieve the ApiAuthService instance.
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();

    // Debug print the token to check if it's being retrieved correctly.
    debugPrint('Token: $token');

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
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
    // Optionally, get the current user if needed.
    RepositoryProvider.of<ApiAuthService>(context).getCurrentUser().then((user) {
      // Use user info if needed.
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
          final apiCategories = data['categories'] as List<dynamic>? ?? [];
          final availableCategories = staticCategories
              .where((cat) => apiCategories
                  .any((apiCat) => apiCat['build_category'] == cat))
              .toList();

          final featuredBuilds = data['featuredBuilds'] as List<dynamic>? ?? [];
          final builds = data['builds'] as List<dynamic>? ?? [];
          final followingBuilds =
              data['followingBuilds'] as List<dynamic>? ?? [];
          final tags = data['tags'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories Section (Horizontal Scroll)
                  const Text(
                    'Browse by Categories',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableCategories.length,
                      itemBuilder: (context, index) {
                        final category = availableCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/categories-view',
                                arguments: {'category': category},
                              );
                            },
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              label: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  category,
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

                  const Divider(),

                  // Browse by Tags (Horizontal Scroll)
                  const Text(
                    'Browse by Tags',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
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

                  const Divider(),

                  // Featured Builds
                  if (featuredBuilds.isNotEmpty) ...[
                    const Text(
                      'Featured Builds',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    buildGrid(featuredBuilds, 3),
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
                    buildGrid(followingBuilds, 3),

                  const Divider(),

                  // Browse Builds
                  const Text(
                    'Recently Updated',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  buildGrid(builds, 3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
