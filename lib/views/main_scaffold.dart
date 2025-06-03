// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/auth/bloc/auth_state.dart';
import 'package:pd/services/api/garage_controller.dart';
import 'package:pd/services/api/maintenance_controller.dart';
import 'package:pd/utilities/dialogs/search_dialog.dart';
import 'package:pd/utilities/dialogs/posts/post_dialog.dart';
import 'package:pd/views/home_view.dart';
import 'package:pd/views/garage_view.dart';
import 'package:pd/views/feedback_view.dart';
import 'package:pd/views/search_results_view.dart';
import 'package:pd/views/builds/modifications/create_modification_view.dart';
import 'package:pd/utilities/dialogs/maintenance/create_maintenance_record_dialog.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.overrideChild});
  final Widget? overrideChild;

  @override
  _MainScaffoldState createState() => _MainScaffoldState();
}

enum _PostType { uploadMedia, modification, note, maintenance }

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  Widget? _overrideChild;
  int? _garageUserId;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _overrideChild = widget.overrideChild;
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

  Future<int?> _selectBuild(List<dynamic> builds) {
    return showModalBottomSheet<int>(
      context: context,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: builds.map((b) {
            final buildMap = Map<String, dynamic>.from(b as Map);
            final year = buildMap['year']?.toString() ?? '';
            final make = buildMap['make']?.toString() ?? '';
            final model = buildMap['model']?.toString() ?? '';
            final trim = buildMap['trim']?.toString() ?? '';
            final title = [year, make, model, trim].where((s) => s.isNotEmpty).join(' ').trim();
            return ListTile(
              title: Text(title.isNotEmpty ? title : 'Unknown Build'),
              onTap: () => Navigator.pop(
                context,
                buildMap['id'] is int ? buildMap['id'] as int : int.tryParse(buildMap['id'].toString()) ?? -1,
              ),
            );
          }).toList(),
        ),
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
            title: const Text('Post to Thread'),
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
          ListTile(
            leading: const Icon(Icons.build_circle),
            title: const Text('Record Maintenance'),
            onTap: () => Navigator.pop(context, _PostType.maintenance),
          ),
        ],
      ),
    );
    if (choice == null || _garageUserId == null) return;

    final data = await fetchGarageData(context: context, userId: _garageUserId!);
    final builds = data['builds'] as List<dynamic>? ?? [];
    final chosenId = await _selectBuild(builds);
    if (chosenId == null || chosenId == -1) return;

    switch (choice) {
      case _PostType.uploadMedia:
        final result = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => PostDialog(buildId: chosenId, reloadBuildData: () async {}),
        );
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Additional media added successfully.')),
          );
        }
        break;

      case _PostType.modification:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateModificationView(buildId: chosenId),
          ),
        );
        break;

      case _PostType.note:
        Navigator.pushNamed(
          context,
          '/manage-note',
          arguments: {'buildId': chosenId},
        );
        break;

      case _PostType.maintenance:
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (dialogContext) => MaintenanceRecordFormDialog(),
        );

        if (result != null) {
          final success = await MaintenanceRecordService(baseUrl: "https://passiondrivenbuilds.com/api")
              .createMaintenanceRecord(
            context,
            buildId: chosenId,
            date: result['date'] is DateTime ? result['date'] : DateTime.tryParse(result['date'] ?? ''),
            description: result['description']!,
            odometer: result['odometer'],
            servicedBy: result['servicedBy'],
            cost: result['cost'],
          );

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maintenance record saved.')),
            );
          }
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).appBarTheme.backgroundColor!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedOut) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      child: Scaffold(
        body: _overrideChild ??
            IndexedStack(
              index: _currentIndex,
              children: [
                const HomeView(),
                if (_garageUserId != null)
                  GarageView(userId: _garageUserId!)
                else
                  const Center(child: CircularProgressIndicator()),
                const SizedBox.shrink(),
                (_searchQuery != null)
                    ? SearchResultsView(key: ValueKey(_searchQuery), query: _searchQuery!)
                    : const Center(child: Text('No search yet')),
                const FeedbackView(),
              ],
            ),
        bottomNavigationBar: SizedBox(
          height: 80,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: bg,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            iconSize: 20,
            selectedFontSize: 0,
            unselectedFontSize: 0,
            currentIndex: _currentIndex,
            onTap: (i) async {
              switch (i) {
                case 0:
                  setState(() {
                    _overrideChild = null;
                    _currentIndex = 0;
                  });
                  break;
                case 1:
                  if (_garageUserId == null) return;
                  setState(() {
                    _overrideChild = null;
                    _currentIndex = 1;
                  });
                  break;
                case 2:
                  await _showPostOptions();
                  break;
                case 3:
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
                  _showMoreMenu();
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.garage), label: ''),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.add, size: 32, color: Colors.white),
                ),
                label: '',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: ''),
            ],
          ),
        ),
      ),
    );
  }
}
