// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/post_controller.dart';
import 'package:pd/widgets/post_card.dart';

class PostListView extends StatefulWidget {
  final String buildId;

  const PostListView({super.key, required this.buildId});

  @override
  _PostListViewState createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadNextPage();

    // Attach a listener to detect when we're near the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts = await PostService()
          .fetchPaginatedPostsForBuild(
            buildId: widget.buildId,
            page: _currentPage,
            pageSize: _pageSize,
            context: context,
          );

      setState(() {
        _posts.addAll(newPosts);
        _isLoading = false;
        _currentPage += 1;
        // If fewer than pageSize are returned, we've reached the end:
        if (newPosts.length < _pageSize) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
      // Optionally show a SnackBar or log the error
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
    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _posts.length) {
          // Each post JSON is a Map<String, dynamic>
          final postData = _posts[index] as Map<String, dynamic>;
          return PostCard(postData: postData);
        } else {
          // Show a loading indicator at the bottom
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
