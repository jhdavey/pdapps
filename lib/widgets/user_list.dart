import 'package:flutter/material.dart';

class UserListView extends StatelessWidget {
  final List<dynamic> users;
  final String title;

  const UserListView({
    super.key,
    required this.users,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: user['profile_image'] != null &&
                      user['profile_image'].toString().trim().isNotEmpty
                  ? NetworkImage(user['profile_image'])
                  : const AssetImage('assets/images/profile_placeholder.png')
                      as ImageProvider,
            ),
            title: Text(user['name'] ?? 'Unknown'),
            onTap: () {
              Navigator.pushNamed(context, '/garage', arguments: user['id']);
            },
          );
        },
      ),
    );
  }
}
