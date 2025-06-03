// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/garage_controller.dart';
import 'package:pd/utilities/dialogs/search_dialog.dart';
import 'package:pd/utilities/dialogs/post_dialog.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/garage_view.dart';
import 'package:pd/views/feedback_view.dart';
import 'package:pd/views/search_results_view.dart';
import 'package:pd/views/builds/modifications/create_modification_view.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    this.overrideChild,
  });

  final Widget? overrideChild;

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

enum _PostType { uploadMedia, modification, note }

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  /// “_overrideChild” starts out from widget.overrideChild but may be cleared
  /// once the user taps “Home” or “Garage.”
  Widget? _overrideChild;

  int? _garageUserId;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    // Initialize our internal overrideChild from the widget parameter.
    _overrideChild = widget.overrideChild;

    // Grab the current (logged-in) user ID so we can show their garage tab.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = RepositoryProvider.of<ApiAuthService>(context);
      final u = await auth.getCurrentUser();
      if (mounted && u != null) {
        setState(() => _garageUserId = int.tryParse(u.id));
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
              // Switch to Feedback tab (index 4). Override stays cleared.
              setState(() {
                _overrideChild = null;
                _currentIndex = 4;
              });
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

  Future<void> _showPostOptions() async {
    final choice = await showModalBottomSheet<_PostType>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Create Post'),
            onTap: () => Navigator.pop(context, _PostType.uploadMedia),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('Add Modification'),
            onTap: () => Navigator.pop(context, _PostType.modification),
          ),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('Add Build Note'),
            onTap: () => Navigator.pop(context, _PostType.note),
          ),
        ],
      ),
    );
    if (choice == null) return;

    switch (choice) {
      case _PostType.uploadMedia:
        // --- First choose a build, then show AdditionalMediaDialog ---
        if (_garageUserId == null) return;
        final data = await fetchGarageData(
          context: context,
          userId: _garageUserId!,
        );
        final builds = data['builds'] as List<dynamic>? ?? [];

        final chosenId = await showModalBottomSheet<int>(
          context: context,
          builder: (_) => ListView(
            children: builds.map((b) {
              final buildMap = (b is Map)
                  ? Map<String, dynamic>.from(b)
                  : <String, dynamic>{};
              final year = buildMap['year']?.toString() ?? '';
              final make = buildMap['make']?.toString() ?? '';
              final model = buildMap['model']?.toString() ?? '';
              final trim = buildMap['trim']?.toString() ?? '';
              final title = [year, make, model, trim]
                  .where((s) => s.isNotEmpty)
                  .join(' ')
                  .trim();
              return ListTile(
                title: Text(title.isNotEmpty ? title : 'Unknown Build'),
                onTap: () => Navigator.pop(
                  context,
                  buildMap['id'] is int
                      ? (buildMap['id'] as int)
                      : int.tryParse(buildMap['id'].toString()) ?? -1,
                ),
              );
            }).toList(),
          ),
        );
        if (chosenId != null && chosenId != -1) {
          final bool? result = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return PostDialog(
                buildId: chosenId,
                reloadBuildData: () async {}, // no-op
              );
            },
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Additional media added successfully.')),
            );
          }
        }
        break;

      case _PostType.modification:
        if (_garageUserId == null) return;
        final data2 = await fetchGarageData(
          context: context,
          userId: _garageUserId!,
        );
        final builds2 = data2['builds'] as List<dynamic>? ?? [];
        await showModalBottomSheet<void>(
          context: context,
          builder: (_) => ListView(
            children: builds2.map((b) {
              final buildMap = (b is Map)
                  ? Map<String, dynamic>.from(b)
                  : <String, dynamic>{};
              final year = buildMap['year']?.toString() ?? '';
              final make = buildMap['make']?.toString() ?? '';
              final model = buildMap['model']?.toString() ?? '';
              final trim = buildMap['trim']?.toString() ?? '';
              final title = [year, make, model, trim]
                  .where((s) => s.isNotEmpty)
                  .join(' ')
                  .trim();
              return ListTile(
                title: Text(title.isNotEmpty ? title : 'Unknown Build'),
                onTap: () {
                  Navigator.pop(context);
                  final buildId = buildMap['id'] is int
                      ? (buildMap['id'] as int)
                      : int.tryParse(buildMap['id'].toString()) ?? -1;
                  if (buildId != -1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateModificationView(buildId: buildId),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
        );
        break;

      case _PostType.note:
        if (_garageUserId == null) return;
        final data3 = await fetchGarageData(
          context: context,
          userId: _garageUserId!,
        );
        final builds3 = data3['builds'] as List<dynamic>? ?? [];
        final chosenId3 = await showModalBottomSheet<int>(
          context: context,
          builder: (_) => ListView(
            children: builds3.map((b) {
              final buildMap = (b is Map)
                  ? Map<String, dynamic>.from(b)
                  : <String, dynamic>{};
              final year = buildMap['year']?.toString() ?? '';
              final make = buildMap['make']?.toString() ?? '';
              final model = buildMap['model']?.toString() ?? '';
              final trim = buildMap['trim']?.toString() ?? '';
              final title = [year, make, model, trim]
                  .where((s) => s.isNotEmpty)
                  .join(' ')
                  .trim();
              return ListTile(
                title: Text(title.isNotEmpty ? title : 'Unknown Build'),
                onTap: () => Navigator.pop(
                  context,
                  buildMap['id'] is int
                      ? (buildMap['id'] as int)
                      : int.tryParse(buildMap['id'].toString()) ?? -1,
                ),
              );
            }).toList(),
          ),
        );
        if (chosenId3 != null && chosenId3 != -1) {
          Navigator.pushNamed(
            context,
            '/manage-note',
            arguments: {'buildId': chosenId3},
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).appBarTheme.backgroundColor!;

    // If overrideChild is non-null, show it full screen (with bottom bar still visible).
    final Widget bodyContent = _overrideChild ??
        IndexedStack(
          index: _currentIndex,
          children: [
            // index 0 → Home
            const HomeView(),

            // index 1 → Garage (if logged in)
            if (_garageUserId != null)
              GarageView(userId: _garageUserId!)
            else
              const Center(child: CircularProgressIndicator()),

            // index 2 → (unused slot)

            // index 3 → SearchResultsView (once a query exists)
            if (_searchQuery != null)
              SearchResultsView(
                  key: ValueKey(_searchQuery), query: _searchQuery!)
            else
              const Center(child: Text('No search yet')),

            // index 4 → Feedback
            const FeedbackView(),
          ],
        );

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: bg,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,

          // shrink icon/text sizes to fit in 48 px
          iconSize: 20,
          selectedFontSize: 0,
          unselectedFontSize: 0,

          currentIndex: _currentIndex,
          onTap: (i) async {
            switch (i) {
              case 0:
                // Home
                setState(() {
                  _overrideChild = null;
                  _currentIndex = 0;
                });
                break;
              case 1:
                // Garage (if logged in)
                if (_garageUserId == null) return;
                setState(() {
                  _overrideChild = null;
                  _currentIndex = 1;
                });
                break;
              case 2:
                // “Post” in the middle
                await _showPostOptions();
                break;
              case 3:
                // Search
                final result = await showSearchDialog(context);
                if (result != null && result.isNotEmpty) {
                  setState(() {
                    _overrideChild = null;
                    _searchQuery = result;
                    _currentIndex = 3;
                  });
                }
                break;
              case 4:
                // More (Feedback / Logout)
                _showMoreMenu();
                break;
              default:
                break;
            }
          },
          items: [
            // Home
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),

            // Garage
            const BottomNavigationBarItem(
              icon: Icon(Icons.garage),
              label: '',
            ),

            // Post (larger & colored circle)
            BottomNavigationBarItem(
              icon: Container(
                margin: const EdgeInsets.only(bottom: 4),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              label: '',
            ),

            // Search
            const BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '',
            ),

            // More (Feedback / Logout)
            const BottomNavigationBarItem(
              icon: Icon(Icons.more_vert),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
