// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';
import 'package:pd/services/api/auth/bloc/auth_bloc.dart';
import 'package:pd/services/api/auth/bloc/auth_event.dart';
import 'package:pd/services/api/build/get_all_builds.dart';
import 'package:pd/data/build_categories.dart';
import 'package:pd/main.dart';
import 'package:pd/utilities/dialogs/search_dialog.dart';
import 'package:pd/widgets/build_horizontal_list.dart';
import 'package:pd/widgets/build_vertical_list.dart';
import 'package:pd/widgets/refreshable_content.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware {
  late Future<Map<String, dynamic>> _buildData;

  @override
  void initState() {
    super.initState();
    _buildData = fetchBuildData(context: context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _buildData = fetchBuildData(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<ApiAuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logoFull.png',
          height: 36,
        ),
        actions: [
          // Garage Button
          IconButton(
            icon: const Icon(Icons.garage),
            onPressed: () async {
              final user = await authService.getCurrentUser();
              if (user != null) {
                final result = await Navigator.of(context).pushNamed(
                  '/garage',
                  arguments: int.tryParse(user.id),
                );
                if (result == true) {
                  setState(() {
                    _buildData = fetchBuildData(context: context);
                  });
                }
              }
            },
          ),
          // Search Button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchDialog(context);
            },
          ),
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(const AuthEventLogOut());
              } else if (value == 'feedback') {
                Navigator.pushNamed(context, '/feedback');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'feedback',
                child: Text('Feedback'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: RefreshableContent(
        onRefresh: () async {
          setState(() {
            _buildData = fetchBuildData(context: context);
          });
          await _buildData;
        },
        child: FutureBuilder<Map<String, dynamic>>(
          future: _buildData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No builds found.'));
            }

            final data = snapshot.data!;
            final apiCategories = data['categories'] as List<dynamic>? ?? [];
            final availableCategories = staticCategories
                .where((cat) => apiCategories
                    .any((apiCat) => apiCat['build_category'] == cat))
                .toList();

            final featuredBuilds =
                data['featuredBuilds'] as List<dynamic>? ?? [];
            final followingBuilds =
                data['followingBuilds'] as List<dynamic>? ?? [];
            final tags = data['tags'] as List<dynamic>? ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  // Categories section
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableCategories.length,
                      itemBuilder: (context, index) {
                        final category = availableCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/categories-view',
                                arguments: {'category': category},
                              );
                            },
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              label: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  // Tags section
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: tags.length,
                      itemBuilder: (context, index) {
                        final tag = tags[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                '/tag-view',
                                arguments: {'tag': tag},
                              );
                            },
                            child: Chip(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              label: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  tag['name'] ?? 'Tag',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  // Featured Builds Section
                  if (featuredBuilds.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Featured',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildHorizontalList(featuredBuilds),
                  ],
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Following',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (followingBuilds.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: const Text('You are not following anyone yet.'),
                    )
                  else
                    buildHorizontalList(followingBuilds),
                  const Divider(),
                  // Recently Updated Builds Section
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Recently Updated',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InfiniteVerticalBuildList(
                    initialBuilds: [],
                    fetchMoreBuilds: (page) async {
                      return await fetchPaginatedBuilds(
                        page: page,
                        pageSize: 5,
                        context: context,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
