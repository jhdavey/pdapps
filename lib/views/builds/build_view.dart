import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pd/views/builds/modifications/create_modification_view.dart';
import 'package:pd/views/builds/modifications/edit_modification_view.dart';
import 'package:pd/views/builds/notes/create_note_view.dart';
import 'package:pd/views/builds/notes/edit_note_view.dart';

class BuildView extends StatefulWidget {
  const BuildView({super.key});

  @override
  State<BuildView> createState() => _BuildViewState();
}

class _BuildViewState extends State<BuildView> {
  late Map<String, dynamic> _build;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        if (args.containsKey('build')) {
          _build = args['build'] as Map<String, dynamic>;
          // If modificationsByCategory was passed, use it.
          if (args.containsKey('modificationsByCategory')) {
            _build['modificationsByCategory'] = args['modificationsByCategory'];
          }
          // If notes were passed, use them.
          if (args.containsKey('notes')) {
            _build['notes'] = args['notes'];
          }
        } else {
          _build = args;
        }
      } else {
        _build = {};
      }

      // Fetch full build data (including modifications and notes).
      _loadBuildData();

      // Get the current user and determine ownership.
      RepositoryProvider.of<ApiAuthService>(context)
          .getCurrentUser()
          .then((currentUser) {
        if (currentUser != null) {
          final buildUser = _build['user'] as Map<String, dynamic>?;
          if (buildUser != null && buildUser.containsKey('id')) {
            final buildUserId = buildUser['id'].toString();
            final currentUserId = currentUser.id.toString();
            debugPrint('buildUser id: $buildUserId vs currentUser id: $currentUserId');
            _build['is_owner'] = buildUserId == currentUserId;
          } else {
            _build['is_owner'] = false;
          }
          setState(() {});
        }
      });
      _initialized = true;
      print("Initial build data: $_build");
    }
  }

  Future<void> _loadBuildData() async {
    if (_build.isNotEmpty && _build.containsKey('id')) {
      final buildId = _build['id'];
      final authService = RepositoryProvider.of<ApiAuthService>(context);
      final token = await authService.getToken();
      final String apiUrl = 'https://passiondrivenbuilds.com/api/builds/$buildId';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _build['modificationsByCategory'] = data['modificationsByCategory'];
          _build['notes'] = data['notes'];
        });
      } else {
        debugPrint('Failed to load build data: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _build['user'] ?? {};
    final userName = user['name'] ?? 'Unknown User';
    final bool isOwner = _build['is_owner'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/garage', arguments: user['id']);
          },
          child: Text("$userName's ${_build['build_category'] ?? ''} Build"),
        ),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedBuild = await Navigator.pushNamed(
                      context,
                      '/edit-build-view',
                      arguments: {'build': _build},
                    );
                    if (updatedBuild != null && mounted) {
                      setState(() {
                        _build = updatedBuild as Map<String, dynamic>;
                      });
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(isOwner),
      ),
    );
  }

  Widget _buildContent(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_build['year'] ?? ''} ${_build['make'] ?? ''} ${_build['model'] ?? ''}"
          "${_build['trim'] != null ? ' ${_build['trim']}' : ''}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _build['image'] ?? 'https://via.placeholder.com/780',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        _buildAdditionalImagesSection(),
        _buildTags(_build),
        _buildSection(
          title: 'Specs',
          dataPoints: [
            {'label': 'Horsepower', 'value': _build['hp']},
            {'label': 'Wheel HP', 'value': _build['whp']},
            {'label': 'Torque', 'value': _build['torque']},
            {'label': 'Weight', 'value': _build['weight']},
          ],
        ),
        _buildSection(
          title: 'Performance',
          dataPoints: [
            {'label': '0-60 mph', 'value': _build['zeroSixty']},
            {'label': '0-100 mph', 'value': _build['zeroOneHundred']},
            {'label': 'Quarter Mile', 'value': _build['quarterMile']},
          ],
        ),
        _buildSection(
          title: 'Platform',
          dataPoints: [
            {'label': 'Vehicle Layout', 'value': _build['vehicleLayout']},
            {'label': 'Transmission', 'value': _build['trans']},
            {'label': 'Engine Type', 'value': _build['engineType']},
            {'label': 'Engine Code', 'value': _build['engineCode']},
            {'label': 'Forced Induction', 'value': _build['forcedInduction']},
            {'label': 'Fuel Type', 'value': _build['fuel']},
            {'label': 'Suspension', 'value': _build['suspension']},
            {'label': 'Brakes', 'value': _build['brakes']},
          ],
        ),
        _buildModificationsSection(isOwner),
        const SizedBox(height: 20),
        _buildNotesSection(isOwner),
      ],
    );
  }

  Widget _buildAdditionalImagesSection() {
    final dynamic rawImages = _build['additional_images'];
    if (rawImages is List && rawImages.isNotEmpty) {
      final images = List<String>.from(rawImages);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _showImageDialog(context, images, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSection({required String title, required List<Map<String, dynamic>> dataPoints}) {
    final filteredData = dataPoints.where((data) => data['value'] != null).toList();
    if (filteredData.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.grey[900],
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...filteredData.map(
                (data) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${data['label']}: ${data['value']}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTags(Map<String, dynamic> build) {
    final List tagList = build['tags'] is List ? build['tags'] : [];
    if (tagList.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tagList.map<Widget>((tag) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              label: Container(
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(fontSize: 10, color: Colors.white, height: 1.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModificationsSection(bool isOwner) {
    if (_build['modificationsByCategory'] != null &&
        (_build['modificationsByCategory'] as Map<String, dynamic>).isNotEmpty) {
      final modificationsByCategory =
          _build['modificationsByCategory'] as Map<String, dynamic>;
      return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with "Modifications" and plus icon (only if owner).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Modifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isOwner)
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateModificationView(buildId: _build['id']),
                        ),
                      );
                      if (result == true) {
                        _loadBuildData();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // List the modifications grouped by category.
            ...modificationsByCategory.entries.map((entry) {
              final category = entry.key;
              final modifications = entry.value as List<dynamic>;
              return Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: Colors.grey[800],
                  collapsedBackgroundColor: Colors.grey[900],
                  title: Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                  children: modifications.map((modification) {
                    return ListTile(
                      title: Text(
                        modification['name'] ?? 'Unnamed Modification',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: isOwner
                          ? IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditModificationView(
                                      buildId: _build['id'],
                                      modification: modification,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadBuildData();
                                }
                              },
                            )
                          : null,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Brand: ${modification['brand'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white70)),
                          if (modification['price'] != null)
                            Text('Price: \$${modification['price']}',
                                style: const TextStyle(color: Colors.white70)),
                          if (modification['notes'] != null &&
                              modification['notes'].toString().isNotEmpty)
                            Text(
                              modification['notes'],
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Modifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (isOwner)
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateModificationView(buildId: _build['id']),
                    ),
                  );
                  if (result == true) {
                    _loadBuildData();
                  }
                },
              ),
          ],
        ),
      );
    }
  }

  Widget _buildNotesSection(bool isOwner) {
    final List<dynamic> notes = _build['notes'] as List<dynamic>? ?? [];
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with "Build Notes" and plus icon (only if owner).
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Build Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateNoteView(buildId: _build['id']),
                      ),
                    );
                    if (result == true) {
                      _loadBuildData();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (notes.isEmpty)
            const Text(
              'No build notes have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...notes.map((note) {
              return ListTile(
                title: Text(
                  note['note'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: isOwner
                    ? IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteView(
                                buildId: _build['id'],
                                note: note,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadBuildData();
                          }
                        },
                      )
                    : null,
              );
            }).toList(),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.9),
          body: Stack(
            children: [
              PageView.builder(
                controller: PageController(initialPage: initialIndex),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Hero(
                      tag: images[index],
                      child: GestureDetector(
                        onTap: () {},
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.error, size: 50, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 20,
                    child: Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
