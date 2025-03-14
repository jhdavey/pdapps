import 'package:flutter/material.dart';
import 'package:pd/services/api/search_controller.dart';
import 'package:pd/widgets/builds/build_card.dart';

class SearchResultsView extends StatefulWidget {
  final String query;
  const SearchResultsView({super.key, required this.query});

  @override
  _SearchResultsViewState createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  List<dynamic> _searchResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  Future<void> _performSearch() async {
    final results = await searchBuilds(context, widget.query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Results: "${widget.query}"')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final build = _searchResults[index];
                    return BuildCard(buildData: build);
                  },
                ),
    );
  }
}
