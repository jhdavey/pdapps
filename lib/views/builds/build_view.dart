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
              "$userName's ${build['build_category'] ?? ''}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${build['year']} ${build['make']} ${build['model']}${build['trim'] != null ? ' ${build['trim']}' : ''}",
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity, // Ensure full width
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent nested scrolling
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Display 3 images per row
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1, // Keep images square
                      ),
                      itemCount: build['additional_images'].length,
                      itemBuilder: (context, index) {
                        final images = List<String>.from(build[
                            'additional_images']); // Convert dynamic list to List<String>

                        return GestureDetector(
                          onTap: () => _showImageDialog(context, images,
                              index), // Pass image list and index
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
              ),

            // Vehicle Data Sections
            _buildSection(
              title: 'Specs',
              dataPoints: [
                {'label': 'Horsepower', 'value': build['hp']},
                {'label': 'Wheel HP', 'value': build['whp']},
                {'label': 'Torque', 'value': build['torque']},
                {'label': 'Weight', 'value': build['weight']},
              ],
            ),
            _buildSection(
              title: 'Performance',
              dataPoints: [
                {'label': '0-60 mph', 'value': build['zeroSixty']},
                {'label': '0-100 mph', 'value': build['zeroOneHundred']},
                {'label': 'Quarter Mile', 'value': build['quarterMile']},
              ],
            ),
            _buildSection(
              title: 'Platform',
              dataPoints: [
                {'label': 'Vehicle Layout', 'value': build['vehicleLayout']},
                {'label': 'Transmission', 'value': build['trans']},
                {'label': 'Engine Type', 'value': build['engineType']},
                {'label': 'Engine Code', 'value': build['engineCode']},
                {
                  'label': 'Forced Induction',
                  'value': build['forcedInduction']
                },
                {'label': 'Fuel Type', 'value': build['fuel']},
                {'label': 'Suspension', 'value': build['suspension']},
                {'label': 'Brakes', 'value': build['brakes']},
              ],
            ),

            // Modifications
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

  Widget _buildSection(
      {required String title, required List<Map<String, dynamic>> dataPoints}) {
    final filteredData =
        dataPoints.where((data) => data['value'] != null).toList();

    if (filteredData.isEmpty)
      return const SizedBox(); // Don't render if no data is available

    return SizedBox(
      width: double.infinity, // Ensure full width
      child: Card(
        color: Colors.grey[850], // Light grey background
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
              ...filteredData.map((data) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      "${data['label']}: ${data['value']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  )),
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
      barrierDismissible: true, // Allows tapping outside to close
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor:
              Colors.black.withOpacity(0.9), // Dark overlay background
          body: Stack(
            children: [
              PageView.builder(
                controller: PageController(
                    initialPage: initialIndex), // Start at tapped image
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Hero(
                      tag: images[index], // Smooth animation effect
                      child: GestureDetector(
                        onTap:
                            () {}, // Prevents accidental closing when tapping image
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain, // Ensure proper fit on screen
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                  child: Icon(Icons.error,
                                      size: 50, color: Colors.white)),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Close Button (Top Right)
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
