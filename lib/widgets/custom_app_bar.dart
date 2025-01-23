// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_service.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<ApiAuthService>(context);

    return AppBar(
      title: Text(title),
      actions: [
        // Garage Button
        IconButton(
          icon: const Icon(Icons.garage),
          onPressed: () async {
            final user = await authService.getCurrentUser();
            if (user != null) {
              Navigator.of(context).pushNamed(
                '/garage',
                arguments: int.tryParse(user.id),
              );
            } else {
            }
          },
        ),

        // Three-Dot Menu
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              context.read<AuthBloc>().add(const AuthEventLogOut());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
