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
            const SizedBox(height: 10),
            Image.network(
              build['image'] ?? 'https://via.placeholder.com/780',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
            // Additional Images Section
            if (build['additional_images'] != null &&
                (build['additional_images'] as List<dynamic>).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Additional Images',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (build['additional_images'] as List<dynamic>)
                        .map((image) {
                      if (image is String) {
                        return Image.network(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return const SizedBox(); // Safeguard for non-string values
                      }
                    }).toList(),
                  ),
                ],
              ),

            // Vehicle Specs
            const SizedBox(height: 20),
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
