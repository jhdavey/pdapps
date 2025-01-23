// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth_service.dart';
import 'dart:convert';
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

    // Fetch the current user using the authService
    authService.getCurrentUser().then((user) {
      if (user != null) {
      } else {
      }
    });

    return CustomScaffold(
      title: 'Passion Driven Builds',
      body: FutureBuilder<Map<String, dynamic>>(
        future: _buildData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found.'));
          }

          final data = snapshot.data!;
          final featuredBuilds = data['featuredBuilds'] as List<dynamic>? ?? [];
          final builds = data['builds'] as List<dynamic>? ?? [];
          final followingBuilds =
              data['followingBuilds'] as List<dynamic>? ?? [];
          final categories = data['categories'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Builds
                  if (featuredBuilds.isNotEmpty) ...[
                    const Text(
                      'Featured Builds',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildGrid(featuredBuilds, 3),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),

                  // Following Builds
                  const Text(
                    'Following',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map(
                          (category) => Chip(
                            label:
                                Text(category['build_category'] ?? 'Unknown'),
                          ),
                        )
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Browse Builds
                  const Text(
                    'Recently Updated',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

  // Helper function to build grid view
  Widget _buildGrid(List<dynamic> items, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio:
            3 / 4, // Allows space for image, username, and build info
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        // Safeguard against invalid data
        if (item is! Map<String, dynamic>) {
          return const Center(
            child: Text('Invalid build data.'),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              '/build-view',
              arguments: item, // Pass the entire item
            );
          },
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image with aspect ratio
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    item['image'] ?? 'https://via.placeholder.com/150',
                    fit: BoxFit.cover,
                  ),
                ),
                // User's name
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    item['user'] != null && item['user']['name'] != null
                        ? "${item['user']['name']}'s"
                        : 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Build year, make, and model
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '${item['year']} ${item['make']} ${item['model']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2, // Prevent overflow
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
