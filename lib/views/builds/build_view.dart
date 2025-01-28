import 'package:flutter/material.dart';

class BuildView extends StatelessWidget {
  const BuildView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> build =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Safely access user data from the build object
    final user = build['user'] ?? {};
    final userName = user['name'] ?? 'Unknown User';

    final bool isOwner = build['is_owner'] ?? false;

    print(build); // Debugging the build data

    return Scaffold(
      appBar: AppBar(
        title: Text("$userName's Build"),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/edit-build-view',
                      arguments: {
                        'build': build, // Pass the full build data directly
                      },
                    );
                  },
                ),
              ]
            : null, // Do not show actions if the user is not the owner
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Featured Image
            Text(
              "$userName's ${build['year']} ${build['make']} ${build['model']} ${build['trim'] ?? ''}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${build['build_category']} Build",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Image.network(
              build['image'] ?? 'https://via.placeholder.com/780',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            const SizedBox(height: 20),

            // Additional Images Section
            if (build['additional_images'] != null &&
                (build['additional_images'] as List<dynamic>).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (build['additional_images'] as List<dynamic>)
                        .map((image) {
                      if (image is String && image.isNotEmpty) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    }).toList(),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // Vehicle Specs
            const Text(
              'Vehicle Specs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSpecsSection(build),

            // Modifications
            const SizedBox(height: 20),
            const Text(
              'Modifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (build['modificationsByCategory'] != null &&
                (build['modificationsByCategory'] as Map<String, dynamic>)
                    .isNotEmpty)
              ...build['modificationsByCategory'].entries.map((entry) {
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
              }).toList()
            else
              const Text('No modifications have been added yet.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecsSection(Map<String, dynamic> build) {
    final List<Map<String, dynamic>> specs = [
      {'label': 'Horsepower', 'value': build['hp']},
      {'label': 'Wheel HP', 'value': build['whp']},
      {'label': 'Torque', 'value': build['torque']},
      {'label': 'Weight', 'value': build['weight']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: specs
          .where((spec) => spec['value'] != null)
          .map((spec) => Text('${spec['label']}: ${spec['value']}'))
          .toList(),
    );
  }
}
