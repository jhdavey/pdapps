// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show ReadContext;
import 'package:pd/constants/routes.dart';
import 'package:pd/enums/menu_action.dart';
import 'package:pd/services/auth/auth_service.dart';
import 'package:pd/services/auth/bloc/auth_bloc.dart';
import 'package:pd/services/auth/bloc/auth_event.dart';
import 'package:pd/services/cloud/cloud_build.dart';
import 'package:pd/services/cloud/firebase_cloud_storage.dart';
import 'package:pd/utilities/dialogs/logout_dialog.dart';
import 'package:pd/views/builds/builds_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final FirebaseCloudStorage _buildsService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _buildsService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Builds'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateBuildRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    context.read<AuthBloc>().add(
                          const AuthEventLogOut(),
                        );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Log out'),
                ),
              ];
            },
          )
        ],
      ),
      body: StreamBuilder(
        stream: _buildsService.allBuilds(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allBuilds = snapshot.data as Iterable<CloudBuild>;
                return BuildListView.BuildListView(
                  builds: allBuilds,
                  onDeleteBuild: (build) async {
                    await _buildsService.deleteBuild(
                        documentId: build.documentId);
                  },
                  onTap: (build) {
                    Navigator.of(context).pushNamed(
                      createOrUpdateBuildRoute,
                      arguments: build,
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
