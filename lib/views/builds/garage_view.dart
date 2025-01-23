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
  final args = ModalRoute.of(context)?.settings.arguments;

  // If arguments weren't passed, fall back to the currently logged in user's ID & name
  int userId;
  String displayName;
  if (args is List) {
    userId = args[0] as int;
    displayName = args[1] as String;
  } else {
    // Replace these with your real logic for a “default” garage
    userId = AuthService.instance.currentUser?.id ?? 0;
    displayName = AuthService.instance.currentUser?.displayName ?? 'You';
  }

    return Scaffold(
      appBar: AppBar(
        title: Text("$displayName's Garage"),
      ),
      body: FutureBuilder<List<Build>>(
        future: _getUserBuilds(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final builds = snapshot.data!;
            return ListView.builder(
              itemCount: builds.length,
              itemBuilder: (context, index) {
                final build = builds[index];
                return ListTile(
                  title: Text('${build.year} ${build.make} ${build.model}'),
                  trailing: IconButton(
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
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No builds found.'));
          }
        },
      ),
    );
  }
}
