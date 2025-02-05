// ignore_for_file: library_private_types_in_public_api, prefer_final_fields, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:pd/services/api/auth/auth_service.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  _GarageViewState createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  late Future<Map<String, dynamic>> _garageData;
  int? _currentUserId;
  late Future<List<dynamic>> _followers;
  late Future<List<dynamic>> _following;
  bool _isFollowing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access userId passed via Navigator arguments (this is the profile user's id)
    final profileUserId = ModalRoute.of(context)?.settings.arguments as int?;
    if (profileUserId != null) {
      _garageData = _fetchGarageData(profileUserId);
      _followers = _fetchFollowers(profileUserId);
      _following = _fetchFollowing(profileUserId);
      // Get current logged-in user id using your ApiAuthService.
      RepositoryProvider.of<ApiAuthService>(context)
          .getCurrentUser()
          .then((currentUser) {
        setState(() {
          _currentUserId = int.tryParse(currentUser?.id.toString() ?? '');
        });
      });
    } else {
      throw Exception('User ID not provided');
    }
  }

  Future<Map<String, dynamic>> _fetchGarageData(int userId) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();

    final String apiUrl = 'https://passiondrivenbuilds.com/api/garage/$userId';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      return decodedResponse;
    } else {
      throw Exception('Failed to load garage data');
    }
  }

  Future<List<dynamic>> _fetchFollowers(int userId) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    final String apiUrl =
        'https://passiondrivenbuilds.com/api/users/$userId/followers';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['followers'] as List<dynamic>?) ?? [];
    } else {
      throw Exception('Failed to load followers');
    }
  }

  Future<List<dynamic>> _fetchFollowing(int userId) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    final String apiUrl =
        'https://passiondrivenbuilds.com/api/users/$userId/following';
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['following'] as List<dynamic>?) ?? [];
    } else {
      throw Exception('Failed to load following');
    }
  }

  Future<void> _toggleFollow(int profileUserId) async {
    final bool follow = !_isFollowing;
    final String apiUrl;
    http.Response response;

    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();

    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (follow) {
      apiUrl =
          'https://passiondrivenbuilds.com/api/users/$profileUserId/follow';
      response = await http.post(Uri.parse(apiUrl), headers: headers);
    } else {
      apiUrl =
          'https://passiondrivenbuilds.com/api/users/$profileUserId/unfollow';
      response = await http.delete(Uri.parse(apiUrl), headers: headers);
    }

    if (response.statusCode == 200) {
      setState(() {
        _followers = _fetchFollowers(profileUserId);
        _following = _fetchFollowing(profileUserId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileUserId = ModalRoute.of(context)?.settings.arguments as int?;
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Garage"),
        actions: [
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found.'));
          }
          final data = snapshot.data!;
          final user = data['user'];
          final builds = data['builds'] as List<dynamic>? ?? [];
          final isOwner = profileUserId == user['id'];
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([_followers, _following]),
                  builder: (context, snapshotSocial) {
                    if (snapshotSocial.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshotSocial.hasError) {
                      return Center(
                          child: Text(
                              'Error loading social data: ${snapshotSocial.error}'));
                    }
                    final followers = snapshotSocial.data?[0] ?? [];
                    final following = snapshotSocial.data?[1] ?? [];
                    _isFollowing = _currentUserId != null &&
                        followers.any((follower) =>
                            int.tryParse(follower['id'].toString()) ==
                            _currentUserId);
                    return _buildProfileSection(user, followers, following);
                  },
                ),
                const SizedBox(height: 10),
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

  Widget _buildProfileSection(Map<String, dynamic> user,
      List<dynamic> followers, List<dynamic> following) {
    final Map<String, String> socialMedia = {
      'IG': user['instagram'] ?? '',
      'FB': user['facebook'] ?? '',
      'TT': user['tiktok'] ?? '',
      'YT': user['youtube'] ?? '',
    };

    final availableSocialMedia = socialMedia.entries
        .where((entry) => entry.value.trim().isNotEmpty)
        .toList();

    final followerCount = followers.length;
    final followingCount = following.length;

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
              Expanded(
                child: Column(
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
                      "Followers: $followerCount | Following: $followingCount",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (_currentUserId != null && _currentUserId != user['id'])
                ElevatedButton(
                  onPressed: () => _toggleFollow(user['id']),
                  child: Text(_isFollowing ? 'Unfollow' : 'Follow'),
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
            children: availableSocialMedia.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    final url = _getSocialMediaUrl(entry.key, entry.value);
                    final Uri uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      debugPrint("Could not launch $url");
                    }
                  },
                  child: Chip(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    label: Container(
                      height: 28,
                      alignment: Alignment.center,
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getSocialMediaUrl(String platform, String username) {
    switch (platform) {
      case 'IG':
        return 'https://instagram.com/$username';
      case 'FB':
        return 'https://facebook.com/$username';
      case 'TT':
        return 'https://tiktok.com/@$username';
      case 'YT':
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
    final buildWithUser = {
      ...build,
      'user': user,
    };
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed('/build-view', arguments: buildWithUser);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
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
                          horizontal: 4, vertical: 4),
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
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "HP: ${build['hp'] ?? 'N/A'}",
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
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _buildTags(build),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTags(Map<String, dynamic> build) {
    final List tagList = build['tags'] is List ? build['tags'] : [];
    if (tagList.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tagList.map<Widget>((tag) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              label: Container(
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white, height: 1.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
