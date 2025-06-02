// lib/views/home_view.dart
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/get_all_builds.dart';
import 'package:pd/data/build_categories.dart';
import 'package:pd/main.dart';
import 'package:pd/services/api/build/get_paginated_fav_builds_controller.dart';
import 'package:pd/widgets/builds/build_horizontal_list.dart';
import 'package:pd/widgets/builds/build_vertical_list.dart';
import 'package:pd/widgets/builds/infinite_horizontal_fav_list.dart';
import 'package:pd/widgets/refreshable_content.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with RouteAware {
  late Future<Map<String, dynamic>> _buildData;

  // GlobalKey to access the state of the vertical infinite list for “load more.”
  final GlobalKey<InfiniteVerticalBuildListState> verticalListKey =
      GlobalKey<InfiniteVerticalBuildListState>();

  // Outer scroll controller drives the entire page’s scrolling.
  final ScrollController _outerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _buildData = fetchBuildData(context: context);
    _outerScrollController.addListener(_onOuterScroll);
  }

  void _onOuterScroll() {
    if (_outerScrollController.position.pixels >=
            _outerScrollController.position.maxScrollExtent - 200 &&
        verticalListKey.currentState != null &&
        !verticalListKey.currentState!.isLoadingMore &&
        verticalListKey.currentState!.hasMore) {
      verticalListKey.currentState?.loadMore();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _outerScrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Refresh data when returning to this screen
    if (mounted) {
      setState(() {
        _buildData = fetchBuildData(context: context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshableContent(
        controller: _outerScrollController,
        onRefresh: () async {
          if (mounted) {
            setState(() {
              _buildData = fetchBuildData(context: context);
            });
          }
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

            final favoriteBuilds =
                data['favoriteBuilds'] as List<dynamic>? ?? [];
            final topFavoritedBuilds =
                data['topFavoritedBuilds'] as List<dynamic>? ?? [];
            final tags =
                List<dynamic>.from(data['tags'] as List<dynamic>? ?? [])
                  ..shuffle();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo at the top
                  Center(
                    child: Image.asset(
                      'assets/images/logoFull.png',
                      height: 40,
                    ),
                  ),

                  const Divider(),

                  // Categories row
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

                  // Tags row
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

                  // Top 10 favorited builds (if any)
                  if (topFavoritedBuilds.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Top 10',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildHorizontalList(topFavoritedBuilds),
                    const Divider(),
                  ],

                  // “Your Favorite Builds” section
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Your Favorite Builds',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (favoriteBuilds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child:
                          Text("You haven't favorited any builds yet."),
                    )
                  else
                    InfiniteHorizontalFavoriteBuildList(
                      initialBuilds: favoriteBuilds,
                      fetchMoreBuilds: (page) async {
                        return await fetchPaginatedFavoriteBuilds(
                          page: page,
                          pageSize: 10,
                          context: context,
                        );
                      },
                    ),

                  const Divider(),

                  // “Your Feed” header
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'Your Feed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: InfiniteVerticalBuildList(
                      key: verticalListKey,
                      shrinkWrap: true,
                      initialBuilds: [],
                      fetchMoreBuilds: (page) async {
                        return await fetchPaginatedBuilds(
                          page: page,
                          pageSize: 10,
                          context: context,
                        );
                      },
                      isScrollable: false,
                    ),
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
