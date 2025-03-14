// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/helpers/toggle_follow_helper.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/follower_controller.dart';
import 'package:pd/services/api/garage_controller.dart';
import 'package:pd/widgets/garage_profile_section.dart';
import 'package:pd/widgets/builds/build_card.dart';

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
    final profileUserId = ModalRoute.of(context)?.settings.arguments as int?;
    if (profileUserId != null) {
      _garageData = fetchGarageData(context: context, userId: profileUserId);
      _followers = fetchFollowers(context: context, userId: profileUserId);
      _following = fetchFollowing(context: context, userId: profileUserId);

      RepositoryProvider.of<ApiAuthService>(context)
          .getCurrentUser()
          .then((currentUser) {
        if (mounted) {
          setState(() {
            _currentUserId = int.tryParse(currentUser?.id.toString() ?? '');
            debugPrint("DEBUG: Current User ID: $_currentUserId");
          });
        }
      });
    } else {
      throw Exception('User ID not provided');
    }
  }

  Future<void> _toggleFollow(int profileUserId) async {
    await toggleFollowHelper(
      context: context,
      profileUserId: profileUserId,
      currentFollowStatus: _isFollowing,
      onSuccess: (newFollowStatus, newFollowers, newFollowing) {
        setState(() {
          _isFollowing = newFollowStatus;
          _followers = newFollowers;
          _following = newFollowing;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _garageData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Garage");
            } else if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Garage");
            }
            final data = snapshot.data!;
            final userName = data['user']['name'] ?? "Garage";
            return Text("$userName's Garage");
          },
        ),
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
              final garageOwnerId = data['user']['id'];
              if (_currentUserId != null && _currentUserId == garageOwnerId) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/create-update-build');
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _garageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found.'));
          }

          final data = snapshot.data!;
          final user = data['user'];
          final builds = data['builds'] as List<dynamic>? ?? [];
          final isOwner =
              _currentUserId != null && _currentUserId == user['id'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([_followers, _following]),
                  builder: (context, snapshotSocial) {
                    if (snapshotSocial.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white)));
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

                    return ProfileSection(
                      user: user,
                      followers: followers,
                      following: following,
                      currentUserId: _currentUserId,
                      isFollowing: _isFollowing,
                      onToggleFollow: () => _toggleFollow(user['id']),
                      onEditProfile: isOwner
                          ? () => Navigator.of(context)
                              .pushNamed('/edit-profile', arguments: user)
                          : () {},
                    );
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
                      // Ensure each build contains a user property.
                      final enrichedBuild = (build is Map<String, dynamic>)
                          ? {...build, 'user': build['user'] ?? user}
                          : build;
                      if (enrichedBuild is! Map<String, dynamic>) {
                        return const Center(child: Text('Invalid build data.'));
                      }
                      return BuildCard(buildData: enrichedBuild);
                    },
                  )
                else if (isOwner)
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
}
