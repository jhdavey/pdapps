import 'package:flutter/material.dart';
import 'package:pd/views/components/edit_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pd/services/api/report_user.dart';

class ProfileSection extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int? currentUserId;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onEditProfile;

  const ProfileSection({
    super.key,
    required this.user,
    required this.followers,
    required this.following,
    required this.currentUserId,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onEditProfile,
  });

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

  void _showUserOptionsSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      backgroundColor: Colors.grey[900],
      duration: const Duration(seconds: 5),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              reportUser(user, context);
            },
            child: const Text(
              "Report",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              blockUser(user, context);
            },
            child: const Text(
              "Block",
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
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
    final bool isGarageOwner = currentUserId == user['id'];

    return GestureDetector(
      onLongPress: () {
        if (!isGarageOwner) {
          _showUserOptionsSnackBar(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main row with profile image and user info.
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF1F242C),
                      child: ClipOval(
                        child: user['profile_image'] != null &&
                                user['profile_image'].isNotEmpty
                            ? Image.network(
                                user['profile_image'],
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/profile_placeholder.png',
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/profile_placeholder.png',
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${user['name']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/user-list',
                                      arguments: {
                                        'users': followers,
                                        'title': 'Followers'
                                      });
                                },
                                child: Text(
                                  "Followers: $followerCount",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              const Text(
                                "  |  ",
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/user-list',
                                      arguments: {
                                        'users': following,
                                        'title': 'Following'
                                      });
                                },
                                child: Text(
                                  "Following: $followingCount",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user['bio'] ?? "No bio available.",
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 4.0,
                  alignment: WrapAlignment.start,
                  children: availableSocialMedia.map((entry) {
                    return GestureDetector(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        label: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
            if (isGarageOwner)
              Positioned(
                top: 5,
                right: 5,
                child: EditIconButton(
                  onPressed: onEditProfile,
                  iconColor: Colors.white,
                ),
              ),
            if (!isGarageOwner)
              Positioned(
                top: 5,
                right: 5,
                child: SizedBox(
                  width: 70,
                  height: 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: onToggleFollow,
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
