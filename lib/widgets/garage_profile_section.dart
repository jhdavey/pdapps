import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileSection extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<dynamic> followers;
  final List<dynamic> following;
  final int? currentUserId;
  final bool isFollowing;
  final VoidCallback onToggleFollow;

  const ProfileSection({
    super.key,
    required this.user,
    required this.followers,
    required this.following,
    required this.currentUserId,
    required this.isFollowing,
    required this.onToggleFollow,
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

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user['profile_image'] != null &&
                        user['profile_image'].isNotEmpty
                    ? NetworkImage(user['profile_image'])
                    : const AssetImage('assets/images/profile_placeholder.png')
                        as ImageProvider,
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
              if (currentUserId != null && currentUserId != user['id'])
                ElevatedButton(
                  onPressed: onToggleFollow,
                  child: Text(isFollowing ? 'Unfollow' : 'Follow'),
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
}
