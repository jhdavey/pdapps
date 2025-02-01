import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TagView extends StatefulWidget {
  final Map<String, dynamic> tag; // The tag object passed in

  const TagView({Key? key, required this.tag}) : super(key: key);

  @override
  State<TagView> createState() => _TagViewState();
}

class _TagViewState extends State<TagView> {
  late Future<Map<String, dynamic>> _tagData;

  // Fetch tag data (including builds) from the API.
  Future<Map<String, dynamic>> _fetchTagData() async {
    final tagId = widget.tag['id'];
    final String apiUrl = 'https://passiondrivenbuilds.com/api/tags/$tagId';
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load tag data');
    }
  }

  @override
  void initState() {
    super.initState();
    _tagData = _fetchTagData();
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No builds found for this tag.'));
          }

          final data = snapshot.data!;
          final builds = data['builds'] as List<dynamic>? ?? [];

          return builds.isEmpty
              ? const Center(child: Text('No builds found for this tag.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: builds.length,
                  itemBuilder: (context, index) {
                    final build = builds[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed('/build-view', arguments: build);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.network(
                                build['image'] ??
                                    'https://via.placeholder.com/150',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                build['user'] != null &&
                                        build['user']['name'] != null
                                    ? "${build['user']['name']}'s"
                                    : 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '${build['year']} ${build['make']} ${build['model']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
