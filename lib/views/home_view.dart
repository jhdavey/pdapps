// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/local_database.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final LocalDatabase _localDatabase = LocalDatabase.instance;

  // This uses your JOIN query
  Future<List<Map<String, dynamic>>> _getBuildsWithUsers() {
    return _localDatabase.getAllBuildsJoined();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Builds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.garage),
            onPressed: () {
              Navigator.of(context).pushNamed('/garage');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Trigger the logout event via AuthBloc
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getBuildsWithUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: Text('No builds found.'));
            }
          }

          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('No builds found.'));
          }

          return ListView.separated(
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              final make = row['make'] as String;
              final model = row['model'] as String;
              final year = row['year'] as int;
              final displayName = row['displayName'] as String;
              final userId = row['userId'] as int;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$displayName's",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text('$year $make $model'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/garage',
                      arguments: [userId, displayName],
                    );
                  },
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 5),
          );
        },
      ),
    );
  }
}
