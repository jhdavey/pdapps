// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  _GarageViewState createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  late Future<Map<String, dynamic>> _garageData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access userId passed via Navigator arguments
    final userId = ModalRoute.of(context)?.settings.arguments as int?;
    if (userId != null) {
      _garageData = _fetchGarageData(userId);
    } else {
      throw Exception('User ID not provided');
    }
  }

  Future<Map<String, dynamic>> _fetchGarageData(int userId) async {
    final String apiUrl = 'https://passiondrivenbuilds.com/api/garage/$userId';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Error: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to load garage data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Garage"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _garageData,
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
          final user = data['user'];
          final builds = data['builds'] as List<dynamic>? ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildProfileSection(user),
                const SizedBox(height: 10),

                // List of Builds
                if (builds.isNotEmpty)
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: builds.length,
                    itemBuilder: (context, index) {
                      final build = builds[index];
                      return _buildTile(build);
                    },
                  )
                else
                  const Center(
                    child: Text("You haven't created any builds yet."),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> user) {
    final socialMedia = {
      'instagram': user['instagram'],
      'facebook': user['facebook'],
      'tiktok': user['tiktok'],
      'youtube': user['youtube'],
    };

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user['profile_image'] != null
                    ? NetworkImage(
                        user['profile_image'])
                    : const NetworkImage('https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${user['name']}'s Garage",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Followers: ${user['followers'] ?? 0} | Following: ${user['following'] ?? 0}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user['bio'] ?? "No bio available.",
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: socialMedia.entries
                .where((entry) => entry.value != null && entry.value.isNotEmpty)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        final url = _getSocialMediaUrl(entry.key, entry.value);
                        // Open the link (You need a package like `url_launcher` for this)
                        print('Opening URL: $url');
                      },
                      child: Text(entry.key.toUpperCase()),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _getSocialMediaUrl(String platform, String username) {
    switch (platform) {
      case 'instagram':
        return 'https://instagram.com/$username';
      case 'facebook':
        return 'https://facebook.com/$username';
      case 'tiktok':
        return 'https://tiktok.com/@$username';
      case 'youtube':
        return 'https://youtube.com/$username';
      default:
        return '';
    }
  }

  Widget _buildTile(Map<String, dynamic> build) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/build-view',
          arguments: build,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left, taking up 30% of the tile width
              Container(
                width: MediaQuery.of(context).size.width *
                    0.3, // 30% of the screen width
                height: 120, // Full height of the tile
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(
                      build['image'] ?? 'https://via.placeholder.com/150',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16), // Space between the image and text
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category in the top right corner
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          build['build_category'] ?? 'Unknown Category',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Year, Make, Model
                    Text(
                      "${build['year']} ${build['make']} ${build['model']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Horsepower and Torque
                    Row(
                      children: [
                        Text(
                          "HP: ${build['horsepower'] ?? 'N/A'}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Torque: ${build['torque'] ?? 'N/A'}",
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // "Click for Details" in the bottom right corner
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Click for details",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
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
  }
}
