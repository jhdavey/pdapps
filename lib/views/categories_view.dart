import 'package:flutter/material.dart';
import 'package:pd/services/api/category_controller.dart';
import 'package:pd/widgets/builds/build_vertical_list.dart';

class CategoriesView extends StatefulWidget {
  final String category;
  const CategoriesView({super.key, required this.category});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late Future<List<dynamic>> _builds;

  @override
  void initState() {
    super.initState();
    _builds = fetchBuildsByCategory(
      context: context,
      category: widget.category,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Category'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _builds,
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
            return const Center(child: Text('No builds found for this category.'));
          }

          final initialBuilds = snapshot.data!;
          return InfiniteVerticalBuildList(
            shrinkWrap: true, 
            initialBuilds: initialBuilds,
            isScrollable: true,
            // No pagination for categories – for page > 1 we return an empty list.
            fetchMoreBuilds: (page) async {
              if (page > 1) return <dynamic>[];
              return initialBuilds;
            },
          );
        },
      ),
    );
  }
}
