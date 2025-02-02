import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth_service.dart';

class BuildView extends StatefulWidget {
  const BuildView({Key? key}) : super(key: key);

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
      // Retrieve the build data from the route arguments.
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        _build = args;
      } else {
        _build = {};
      }

      // Get the current user and determine ownership.
      RepositoryProvider.of<ApiAuthService>(context)
          .getCurrentUser()
          .then((currentUser) {
        if (currentUser != null) {
          final buildUser = _build['user'] as Map<String, dynamic>?;
          if (buildUser != null && buildUser.containsKey('id')) {
            final buildUserId = buildUser['id'].toString();
            final currentUserId = currentUser.id.toString();
            debugPrint(
                'buildUser id: $buildUserId vs currentUser id: $currentUserId');
            _build['is_owner'] = buildUserId == currentUserId;
          } else {
            _build['is_owner'] = false;
          }
          setState(() {});
        }
      });
      _initialized = true;
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
            // Assuming that the user info is available in a variable `user`
            // and that user['id'] holds the profile user's id.
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
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
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
        const Text(
          'Modifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (_build['modificationsByCategory'] != null &&
            (_build['modificationsByCategory'] as Map<String, dynamic>)
                .isNotEmpty)
          ...(_build['modificationsByCategory'] as Map<String, dynamic>)
              .entries
              .map((entry) {
            final category = entry.key;
            final modifications = entry.value as List<dynamic>;
            return ExpansionTile(
              title: Text(category),
              children: modifications.map((modification) {
                return ListTile(
                  title: Text(modification['name']),
                  subtitle: Text('Brand: ${modification['brand']}'),
                );
              }).toList(),
            );
          })
        else
          const Text('No modifications have been added yet.'),
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

  Widget _buildSection(
      {required String title, required List<Map<String, dynamic>> dataPoints}) {
    final filteredData =
        dataPoints.where((data) => data['value'] != null).toList();
    if (filteredData.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.grey[850],
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

  void _showImageDialog(
      BuildContext context, List<String> images, int initialIndex) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Scaffold(
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
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                            child: Icon(Icons.error,
                                size: 50, color: Colors.white),
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

  // Helper widget to display tags as a horizontal row with clickable chips.
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
              Navigator.of(context)
                  .pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              label: Container(
                height: 28,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(
                      fontSize: 10, color: Colors.white, height: 1.0),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
