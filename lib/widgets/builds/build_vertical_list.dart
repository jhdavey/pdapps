// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pd/widgets/builds/build_card.dart';

class InfiniteVerticalBuildList extends StatefulWidget {
  final List<dynamic> initialBuilds;
  final Future<List<dynamic>> Function(int page) fetchMoreBuilds;
  final bool isScrollable; // if true, let the internal list scroll

  const InfiniteVerticalBuildList({
    super.key,
    required this.initialBuilds,
    required this.fetchMoreBuilds,
    this.isScrollable = false,
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
    // Initialize with provided builds.
    _builds = widget.initialBuilds;
    if (_builds.isEmpty) {
      _loadMore();
    }
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
        shrinkWrap: !widget.isScrollable,
        physics: widget.isScrollable
            ? null
            : const NeverScrollableScrollPhysics(),
        itemCount: _builds.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _builds.length) {
            final build = _builds[index];
            // Use BuildCard widget for each build.
            return BuildCard(buildData: build);
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
}
