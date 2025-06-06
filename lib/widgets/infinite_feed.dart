import 'package:flutter/material.dart';
import 'package:pd/models/feed_item.dart';
import 'package:pd/widgets/builds/build_card.dart';
import 'package:pd/widgets/posts/post_card.dart';

class InfiniteVerticalFeedList extends StatefulWidget {
  final List<FeedItem> initialItems;
  final Future<Map<String, dynamic>> Function(int page) fetchMoreItems;
  final String currentUserId;
  final bool isScrollable;

  const InfiniteVerticalFeedList({
    super.key,
    required this.initialItems,
    required this.fetchMoreItems,
    required this.currentUserId,
    this.isScrollable = false,
  });

  @override
  InfiniteVerticalFeedListState createState() => InfiniteVerticalFeedListState();
}

// Made class public so it can be accessed by GlobalKey<>
class InfiniteVerticalFeedListState extends State<InfiniteVerticalFeedList> {
  late List<FeedItem> _items;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Public getters and method for access via GlobalKey
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  void loadMore() => _loadMore();

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
    if (_items.isEmpty) _loadMore();
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

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await widget.fetchMoreItems(nextPage);

      final List<FeedItem> newItems = List<FeedItem>.from(result['items']);
      final bool newHasMore = result['hasMore'] ?? false;

      if (mounted) {
        setState(() {
          _items.addAll(newItems);
          _currentPage = nextPage;
          _hasMore = newHasMore;
        });
      }
    } catch (e) {
      debugPrint("Feed load error: $e");
      if (mounted) _hasMore = false;
    }

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.isScrollable ? _scrollController : null,
      shrinkWrap: true,
      physics:
          widget.isScrollable ? null : const NeverScrollableScrollPhysics(),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _items.length) {
          final item = _items[index];
          switch (item.type) {
            case 'build':
              return BuildCard(buildData: item.data);
            case 'post':
              return PostCard(
                postData: item.data,
                currentUserId: widget.currentUserId,
              );
            default:
              return const SizedBox.shrink();
          }
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    if (widget.isScrollable) {
      _scrollController.dispose();
    }
    super.dispose();
  }
}
