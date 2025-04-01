// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:pd/views/builds/modifications/create_modification_view.dart';
import 'package:pd/views/builds/modifications/edit_modification_view.dart';

class BuildModificationsSection extends StatelessWidget {
  final Map<String, dynamic> modificationsByCategory;
  final int buildId;
  final bool isOwner;
  final VoidCallback reloadBuildData;

  const BuildModificationsSection({
    super.key,
    required this.modificationsByCategory,
    required this.buildId,
    required this.isOwner,
    required this.reloadBuildData,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasModifications = modificationsByCategory.isNotEmpty;

    Widget content = hasModifications
        ? Column(
            children: modificationsByCategory.entries.map((entry) {
              final String category = entry.key;
              final List<dynamic> mods = entry.value as List<dynamic>;
              return Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: const Color(0xFF1F242C),
                  iconColor: Colors.white,
                  collapsedBackgroundColor: const Color(0xFF1F242C),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 10.0),
                  title: Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                  children: mods.map((modification) {
                    // Build a widget to display modification images if available.
                    Widget imagesWidget = const SizedBox.shrink();
                    if (modification['images'] != null &&
                        modification['images'] is List &&
                        (modification['images'] as List).isNotEmpty) {
                      imagesWidget = SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: (modification['images'] as List).length,
                          itemBuilder: (context, index) {
                            final imageUrl = modification['images'][index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        color: Colors.white),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row with modification name, "Not Installed" indicator, and edit icon.
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      modification['name'] ?? 'Unnamed Modification',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (modification['not_installed'] == 1 ||
                                        modification['not_installed'] == true)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4.0),
                                        child: Text(
                                          'Not Installed',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isOwner)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditModificationView(
                                          buildId: buildId,
                                          modification: modification,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      reloadBuildData();
                                    }
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Full width modification details.
                          if (modification['brand'] != null &&
                              modification['brand'].toString().trim().isNotEmpty)
                            Text(
                              'Brand: ${modification['brand']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          if (modification['price'] != null)
                            Text(
                              'Price: \$${modification['price']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          const SizedBox(height: 10),
                          if (modification['notes'] != null &&
                              modification['notes'].toString().isNotEmpty)
                            Text(
                              modification['notes'],
                              style: const TextStyle(color: Colors.white70),
                            ),
                          const SizedBox(height: 10),
                          if (modification['installed_myself'] == 1 ||
                              (modification['installed_by'] != null &&
                                  modification['installed_by'].toString().isNotEmpty))
                            Text(
                              modification['installed_myself'] == 1
                                  ? "Self-Installed"
                                  : "Installed by: ${modification['installed_by']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          const SizedBox(height: 10),
                          imagesWidget,
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          )
        : const Text(
            'No modifications have been added yet.',
            style: TextStyle(color: Colors.white70),
          );

    if (hasModifications) {
      content = ExpansionTile(
        backgroundColor: const Color(0xFF1F242C),
        iconColor: Colors.white,
        collapsedBackgroundColor: const Color(0xFF1F242C),
        tilePadding: const EdgeInsets.symmetric(horizontal: 0.0),
        title: Row(
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
                      builder: (context) => CreateModificationView(buildId: buildId),
                    ),
                  );
                  if (result == true) {
                    reloadBuildData();
                  }
                },
              ),
          ],
        ),
        children: [content],
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        builder: (context) => CreateModificationView(buildId: buildId),
                      ),
                    );
                    if (result == true) {
                      reloadBuildData();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'No modifications have been added yet.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: content,
    );
  }
}
