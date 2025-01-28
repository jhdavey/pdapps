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
      final decodedResponse = json.decode(response.body);

      return decodedResponse;
    } else {
      throw Exception('Failed to load garage data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Garage"),
        actions: [
          // Add the "+" icon button for the garage owner
          FutureBuilder<Map<String, dynamic>>(
            future: _garageData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.hasError ||
                  !snapshot.hasData) {
                return const SizedBox();
              }

              final data = snapshot.data!;
              final userId = ModalRoute.of(context)?.settings.arguments as int?;
              final isOwner = userId == data['user']['id'];

              if (isOwner) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create-update-build');
                  },
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
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
          final userId = ModalRoute.of(context)?.settings.arguments as int?;
          final isOwner = userId == user['id'];
          

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
                      return _buildTile(
                        build: build,
                        user: user,
                        isOwner: isOwner,
                      );
                    },
                  )
                else
                  const Center(
                    child: Text(
                        "Add your first build by tapping the plus icon in the top right."),
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
                    ? NetworkImage(user['profile_image'])
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
                        _getSocialMediaUrl(entry.key, entry.value);
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

  Widget _buildTile({
    required Map<String, dynamic> build,
    required Map<String, dynamic> user,
    required bool isOwner,
  }) {
    return GestureDetector(
      onTap: () {
        final buildWithUser = {
          ...build,
          'user': user,
          'is_owner': isOwner, // Include isOwner
        };

        Navigator.of(context).pushNamed(
          '/build-view',
          arguments: buildWithUser,
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
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                height: 120,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      "${build['year']} ${build['make']} ${build['model']}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "HP: ${build['hp'] ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Torque: ${build['torque'] ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "Click for details",
                        style: const TextStyle(
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
