// lib/views/builds/build_view.dart
// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pd/helpers/build_ownership_helper.dart';
import 'package:pd/helpers/route_arguments_helper.dart';
import 'package:pd/main.dart';
import 'package:pd/services/api/build/build_data_loader.dart';
import 'package:pd/widgets/builds/build_additional_media_section.dart';
import 'package:pd/widgets/builds/build_comment_section.dart';
import 'package:pd/widgets/builds/build_data_section.dart';
import 'package:pd/widgets/builds/build_modification_section.dart';
import 'package:pd/widgets/builds/build_note_section.dart';
import 'package:pd/widgets/builds/build_tag_section.dart';
import 'package:pd/widgets/favorite_button.dart';
import 'package:pd/widgets/post_card.dart';
import 'package:pd/services/api/post_controller.dart';

class BuildView extends StatefulWidget {
  const BuildView({super.key});

  @override
  State<BuildView> createState() => _BuildViewState();
}

class _BuildViewState extends State<BuildView> with RouteAware {
  late Map<String, dynamic> _build;
  bool _initialized = false;
  String? _currentUserId;

  // For paginated posts:
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _posts = [];
  bool _isLoadingPosts = false;
  bool _hasMorePosts = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
    if (!_initialized) {
      _build = getRouteArguments(context);
      _loadBuildData();
      updateBuildOwnership(context, _build).then((userId) {
        _currentUserId = userId;
        setState(() {});
      });

      // Attach listener to load more posts when near bottom:
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >=
                _scrollController.position.maxScrollExtent - 200 &&
            !_isLoadingPosts &&
            _hasMorePosts) {
          _loadNextPageOfPosts();
        }
      });

      // Kick off first page of posts:
      _loadNextPageOfPosts();

      _initialized = true;
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadBuildData();
  }

  Future<void> _loadBuildData() async {
    if (_build.isNotEmpty && _build.containsKey('id')) {
      final buildId = _build['id'].toString();
      final data = await loadBuildDataHelper(buildId, context);
      if (data != null) {
        setState(() {
          _build = data['build'];
          _build['additional_media'] = data['additional_media'];
          _build['modificationsByCategory'] = data['modificationsByCategory'];
          _build['notes'] = data['notes'];
          _build['comments'] = data['comments'];
          _build['files'] = data['build']['files'];
        });
      }
    }
  }

  Future<void> _loadNextPageOfPosts() async {
    if (_isLoadingPosts || !_hasMorePosts) return;
    setState(() => _isLoadingPosts = true);

    try {
      final newPosts = await PostService().fetchPaginatedPostsForBuild(
        buildId: _build['id'].toString(),
        page: _currentPage,
        pageSize: _pageSize,
        context: context,
      );

      setState(() {
        _posts.addAll(newPosts);
        _currentPage += 1;
        if (newPosts.length < _pageSize) {
          _hasMorePosts = false;
        }
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPosts = false;
        _hasMorePosts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load more posts: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _build['user'] ?? {};
    final userName = user['name'] ?? 'Unknown User';
    final bool isOwner = _currentUserId != null &&
        _build['user_id'].toString() == _currentUserId.toString();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/garage', arguments: user['id']);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "$userName's ${_build['build_category'] ?? ''} Build",
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                'Click here to view profile',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/edit-build-view',
                      arguments: {'build': _build},
                    );
                    if (updated != null && mounted) {
                      setState(() {
                        _build = updated as Map<String, dynamic>;
                      });
                    }
                  },
                ),
              ]
            : null,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeaderAndComments(isOwner),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Text(
                'Build Thread',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < _posts.length) {
                  final postData = _posts[index] as Map<String, dynamic>;
                  return PostCard(postData: postData);
                }
                // Show a loading spinner if we still expect more pages
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              // childCount = number of posts + 1 extra when _hasMorePosts is true
              childCount: _posts.length + (_hasMorePosts ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndComments(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with build title + favorite
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                "${_build['year'] ?? ''} ${_build['make'] ?? ''} ${_build['model'] ?? ''}"
                "${_build['trim'] != null ? ' ${_build['trim']}' : ''}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FavoriteButton(
              buildId: _build['id'],
              initialFavoriteCount: _build['favorite_count'] ?? 0,
              initialIsFavorited: _build['is_favorited'] ?? false,
            ),
          ],
        ),

        // Main image / placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: (_build['image'] != null &&
                  _build['image'].toString().isNotEmpty)
              ? CachedNetworkImage(
                  imageUrl: _build['image'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/placeholder_car_image.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : Image.asset(
                  'assets/images/placeholder_car_image.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        const SizedBox(height: 4),

        // Additional Media
        buildAdditionalMediaSection(
          _build,
          reloadBuildData: _loadBuildData,
          isOwner: isOwner,
        ),
        const SizedBox(height: 8),

        // Tag chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: BuildTags(buildData: _build),
        ),

        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Theme(
              data: ThemeData(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                collapsedBackgroundColor: Theme.of(context).cardTheme.color,
                backgroundColor: Theme.of(context).cardTheme.color,
                iconColor: Colors.white,
                collapsedIconColor: Colors.white,
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                title: const Text(
                  'Build Sheet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 0),
                    child: ExpansionTile(
                      iconColor: Colors.white,
                      collapsedIconColor: Colors.white,
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 0),
                      title: const Text(
                        'Specs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      childrenPadding:
                          EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
                      children: [
                        buildSection(
                          title: 'Specs',
                          dataPoints: [
                            {'label': 'Horsepower', 'value': _build['hp']},
                            {'label': 'Wheel HP', 'value': _build['whp']},
                            {'label': 'Torque', 'value': _build['torque']},
                            {'label': 'Weight', 'value': _build['weight']},
                            {'label': '0-60 mph', 'value': _build['zeroSixty']},
                            {
                              'label': '0-100 mph',
                              'value': _build['zeroOneHundred']
                            },
                            {
                              'label': 'Quarter Mile',
                              'value': _build['quarterMile']
                            },
                            {
                              'label': 'Vehicle Layout',
                              'value': _build['vehicleLayout']
                            },
                            {'label': 'Transmission', 'value': _build['trans']},
                            {
                              'label': 'Engine Type',
                              'value': _build['engineType']
                            },
                            {
                              'label': 'Engine Code',
                              'value': _build['engineCode']
                            },
                            {
                              'label': 'Forced Induction',
                              'value': _build['forcedInduction']
                            },
                            {'label': 'Fuel Type', 'value': _build['fuel']},
                            {
                              'label': 'Suspension',
                              'value': _build['suspension']
                            },
                            {'label': 'Brakes', 'value': _build['brakes']},
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2) Modifications
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BuildModificationsSection(
                      modificationsByCategory: _build['modificationsByCategory']
                              is Map<String, dynamic>
                          ? _build['modificationsByCategory']
                              as Map<String, dynamic>
                          : {},
                      buildId: _build['id'],
                      isOwner: isOwner,
                      reloadBuildData: _loadBuildData,
                    ),
                  ),

                  // 3) Notes
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: BuildNotesSection(
                      notes: _build['notes'] as List<dynamic>? ?? [],
                      buildId: _build['id'],
                      isOwner: isOwner,
                      reloadBuildData: _loadBuildData,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Comments (flat tree) – still part of the same scroll
        BuildCommentsSection(
          comments: _build['comments'] as List<dynamic>? ?? [],
          buildId: _build['id'].toString(),
          currentUserId: _currentUserId,
          reloadBuildData: _loadBuildData,
        ),
      ],
    );
  }
}
