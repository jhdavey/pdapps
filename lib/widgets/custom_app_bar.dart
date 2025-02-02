import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_service.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  // Callback to notify the parent when GarageView returns a result.
  final void Function(bool socialDataChanged)? onGarageResult;

  const CustomAppBar({
    super.key,
    required this.title,
    this.onGarageResult,
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
              // Await the result from GarageView.
              final result = await Navigator.of(context).pushNamed(
                '/garage',
                arguments: int.tryParse(user.id),
              );
              // If a result is returned and it's true, call the callback.
              if (result == true && onGarageResult != null) {
                onGarageResult!(true);
              }
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
