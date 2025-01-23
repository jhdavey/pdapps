import 'package:flutter/material.dart';
import 'package:pd/models/build.dart';
import 'package:pd/services/auth/auth_service.dart';
import 'package:pd/services/local_database.dart';

class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  _GarageViewState createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  final LocalDatabase _localDatabase = LocalDatabase.instance;

  Future<List<Build>> _getUserBuilds(int userId) async {
    final db = await _localDatabase.database;
    final buildMaps = await db.query(
      'builds',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return buildMaps.map((map) => Build.fromMap(map)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which user's garage we are viewing
    final args = ModalRoute.of(context)?.settings.arguments;
    int userId;
    String displayName;
    if (args is List) {
      userId = args[0] as int;
      displayName = args[1] as String;
    } else {
      userId = AuthService.instance.currentUser?.id ?? 0;
      displayName = AuthService.instance.currentUser?.displayName ?? 'You';
    }

    // The currently logged-in user
    final currentUserId = AuthService.instance.currentUser?.id ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Garage of $displayName'),
        // Show plus button only if viewing your own garage
        actions: [
          if (currentUserId == userId)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/create-build',
                  arguments: {
                    'isEdit': false,
                    'buildId': null,
                  },
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(displayName),
            const SizedBox(height: 8),
            FutureBuilder<List<Build>>(
              future: _getUserBuilds(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final builds = snapshot.data!;
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: builds.length,
                    separatorBuilder: (context, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final build = builds[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10.0),
                          title: Text('${build.year} ${build.make} ${build.model}'),
                          // Show delete icon only if we're viewing our own garage
                          trailing: (currentUserId == userId)
                              ? IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    final db = await _localDatabase.database;
                                    await db.delete(
                                      'builds',
                                      where: 'id = ?',
                                      whereArgs: [build.id],
                                    );
                                    setState(() {});
                                  },
                                )
                              : null,
                          // Tap on any build to view its details (read-only or your own)
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/build-view',
                              arguments: {
                                'displayName': displayName,
                                'year': build.year,
                                'make': build.make,
                                'model': build.model,
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No builds found.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String displayName) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Profile pic, display name, follower/following
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    const NetworkImage('https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Followers: 9999',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Following: 345',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bio
          const Text(
            'I love building cars! And this is the most amazing app I have ever seen! Thank you!',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          // Social links
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.link, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('IG: @somehandle',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.link, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('FB: @somehandle',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.link, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('YT: ChannelName',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.link, color: Colors.white70),
                      SizedBox(width: 4),
                      Text('TT: @someotherhandle',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
