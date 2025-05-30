// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/utilities/dialogs/search_dialog.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/garage_view.dart';
import 'package:pd/views/feedback_view.dart';
import 'package:pd/views/search_results_view.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  int? _garageUserId;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Fetch current user ID for Garage tab
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = RepositoryProvider.of<ApiAuthService>(context);
      final user = await authService.getCurrentUser();
      if (mounted && user != null) {
        setState(() => _garageUserId = int.tryParse(user.id));
      }
    });
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthEventLogOut());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).appBarTheme.backgroundColor!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home
          const HomeView(),

          // Garage
          if (_garageUserId != null)
            GarageView(userId: _garageUserId!)
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          if (_searchQuery != null)
            SearchResultsView(
              key: ValueKey(_searchQuery),
              query: _searchQuery!,
            )
          else
            const Center(child: Text('No search yet')),

          // Feedback
          const FeedbackView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: bg,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (i) async {
          if (i == 2) {
            final result = await showSearchDialog(context);
            if (result != null && result.isNotEmpty) {
              setState(() {
                _searchQuery = result;
                _currentIndex = 2;
              });
            }
          } else if (i == 3) {
            _showMoreMenu();
          } else {
            // Home or Garage
            if (i == 1 && _garageUserId == null) return;
            setState(() => _currentIndex = i);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.garage), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: ''),
        ],
      ),
    );
  }
}
