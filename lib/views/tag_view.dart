import 'package:flutter/material.dart';
import 'package:pd/services/api/tag_view_controller.dart';
import 'package:pd/widgets/build_grid.dart';

class TagView extends StatefulWidget {
  final Map<String, dynamic> tag;

  const TagView({super.key, required this.tag});

  @override
  State<TagView> createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  late Future<Map<String, dynamic>> _tagData;

  @override
  void initState() {
    super.initState();
    _tagData = fetchTagData(
      context: context,
      tagId: widget.tag['id'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tag['name'] ?? 'Tag'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _tagData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found for this tag.'));
          }

          final data = snapshot.data!;
          final builds = data['builds'] as List<dynamic>? ?? [];

          return builds.isEmpty
              ? const Center(child: Text('No builds found for this tag.'))
              : buildGrid(builds, 2); 
        },
      ),
    );
  }
}
