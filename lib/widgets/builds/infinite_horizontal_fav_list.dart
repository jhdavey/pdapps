// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:pd/widgets/builds/build_card.dart';

class InfiniteHorizontalFavoriteBuildList extends StatefulWidget {
  final List<dynamic> initialBuilds;
  final Future<List<dynamic>> Function(int page) fetchMoreBuilds;
  // This widget always scrolls horizontally.
  const InfiniteHorizontalFavoriteBuildList({
    Key? key,
    required this.initialBuilds,
    required this.fetchMoreBuilds,
  }) : super(key: key);

  @override
  _InfiniteHorizontalFavoriteBuildListState createState() =>
      _InfiniteHorizontalFavoriteBuildListState();
}

class _InfiniteHorizontalFavoriteBuildListState
    extends State<InfiniteHorizontalFavoriteBuildList> {
  late List<dynamic> _builds;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _builds = List.from(widget.initialBuilds);
    if (_builds.isEmpty) {
      _loadMore();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
  if (_isLoadingMore || !_hasMore) return;
  setState(() {
    _isLoadingMore = true;
  });
  try {
    final newBuilds = await widget.fetchMoreBuilds(_currentPage);
    if (newBuilds.isEmpty) {
      _hasMore = false;
    } else {
      // Filter out duplicates (assume each build has a unique 'id').
      final uniqueNewBuilds = newBuilds.where((build) {
        return !_builds.any((existing) => existing['id'] == build['id']);
      }).toList();
      if (uniqueNewBuilds.isNotEmpty) {
        setState(() {
          _builds.addAll(uniqueNewBuilds);
          _currentPage++;
        });
      } else {
        // If all new items are duplicates, assume no more unique items.
        _hasMore = false;
      }
    }
  } catch (e) {
    debugPrint("Error loading favorites page $_currentPage: $e");
    _hasMore = false;
  }
  if (mounted) {
    setState(() {
      _isLoadingMore = false;
    });
  }
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _builds.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _builds.length) {
            final build = _builds[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/build-view', arguments: build);
              },
              child: SizedBox(
                width: 420,
                child: BuildCard(buildData: build),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
