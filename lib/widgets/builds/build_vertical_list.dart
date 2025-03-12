// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pd/widgets/tag_chip_list.dart';
import 'package:pd/services/api/report_user.dart';

class InfiniteVerticalBuildList extends StatefulWidget {
  final List<dynamic> initialBuilds;
  final Future<List<dynamic>> Function(int page) fetchMoreBuilds;

  const InfiniteVerticalBuildList({
    super.key,
    required this.initialBuilds,
    required this.fetchMoreBuilds,
  });

  @override
  _InfiniteVerticalBuildListState createState() =>
      _InfiniteVerticalBuildListState();
}

class _InfiniteVerticalBuildListState extends State<InfiniteVerticalBuildList> {
  List<dynamic> _builds = [];
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _builds = [];
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      debugPrint("Attempting to load page $_currentPage");
      List<dynamic> moreBuilds = await widget.fetchMoreBuilds(_currentPage);
      debugPrint("Loaded page $_currentPage, count: ${moreBuilds.length}");
      if (moreBuilds.isEmpty) {
        _hasMore = false;
      } else {
        _builds.addAll(moreBuilds);
        _currentPage++;
      }
    } catch (e) {
      debugPrint("Error loading page $_currentPage: $e");
      _hasMore = false;
    }
    setState(() {
      _isLoadingMore = false;
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _builds.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _builds.length) {
            final build = _builds[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/build-view', arguments: build);
              },
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.grey[900],
                    duration: const Duration(seconds: 5),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if (build['user'] != null) {
                              reportUser(build['user'], context);
                            }
                          },
                          child: const Text(
                            "Report",
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            if (build['user'] != null) {
                              blockUser(build['user'], context);
                            }
                          },
                          child: const Text(
                            "Block",
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
                      child: Image.network(
                        build['image'] ?? 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  build['user'] != null &&
                                          build['user']['name'] != null
                                      ? "${build['user']['name']}'s"
                                      : 'Unknown User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${build['year']} ${build['make']} ${build['model']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 18,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                TagChipList(
                                  tags: build['tags'] is List
                                      ? build['tags']
                                      : [],
                                ),
                              ],
                            ),
                          ),
                          // Right Column: Build category.
                          Text(
                            build['build_category'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
