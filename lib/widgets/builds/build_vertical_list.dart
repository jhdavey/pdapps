// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:pd/widgets/builds/build_card.dart';

class InfiniteVerticalBuildList extends StatefulWidget {
  final List<dynamic> initialBuilds;
  final Future<List<dynamic>> Function(int page) fetchMoreBuilds;
  final bool isScrollable; // If true, the list scrolls internally.

  const InfiniteVerticalBuildList({
    Key? key,
    required this.initialBuilds,
    required this.fetchMoreBuilds,
    this.isScrollable = false, required bool shrinkWrap,
  }) : super(key: key);

  @override
  InfiniteVerticalBuildListState createState() =>
      InfiniteVerticalBuildListState();
}

class InfiniteVerticalBuildListState extends State<InfiniteVerticalBuildList> {
  late List<dynamic> _builds;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Public getters to expose loading state.
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  void initState() {
    super.initState();
    _builds = List.from(widget.initialBuilds);
    if (_builds.isEmpty) {
      _loadMore();
    }
    if (widget.isScrollable) {
      _scrollController.addListener(_onScroll);
    }
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
        setState(() {
          _builds.addAll(newBuilds);
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error loading page $_currentPage: $e");
      _hasMore = false;
    }
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Public method to allow external triggering of loading more.
  void loadMore() {
    _loadMore();
  }

  @override
  void dispose() {
    if (widget.isScrollable) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: true,
      physics: widget.isScrollable
          ? null
          : const NeverScrollableScrollPhysics(),
      itemCount: _builds.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _builds.length) {
          final build = _builds[index];
          return BuildCard(buildData: build);
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator(
              color: Colors.white,
            )),
          );
        }
      },
    );
  }
}
