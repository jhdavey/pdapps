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

  void _zoomImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // ↓ EXACTLY THE SAME PADDING/COLOR SETTINGS AS BuildNotesSection ↓
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 6.0),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 6.0),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Modifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateModificationView(
                          buildId: buildId,
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
          children: [
            const SizedBox(height: 10),
            if (modificationsByCategory.isEmpty)
              const Text(
                'No modifications have been added yet.',
                style: TextStyle(color: Colors.white70),
              )
            else
              // … each category is its own nested ExpansionTile …
              ...modificationsByCategory.entries.map((entry) {
                final String category = entry.key;
                final List<dynamic> mods = entry.value as List<dynamic>;

                return Theme(
                  data: ThemeData(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    // And make sure nested tiles also use the same padding:
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                    iconColor: Colors.white,
                    collapsedIconColor: Colors.white,
                    tilePadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 6.0),
                    title: Text(
                      category,
                      style: const TextStyle(color: Colors.white),
                    ),
                    children: mods.map((modification) {
                      Widget imagesWidget = const SizedBox.shrink();
                      if (modification['images'] != null &&
                          (modification['images'] as List).isNotEmpty) {
                        imagesWidget = SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (modification['images'] as List).length,
                            itemBuilder: (context, index) {
                              final imageUrl =
                                  (modification['images'] as List)[index];
                              return GestureDetector(
                                onTap: () => _zoomImage(context, imageUrl),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.network(
                                    imageUrl,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, st) =>
                                        const Icon(Icons.broken_image,
                                            color: Colors.white),
                                  ),
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
                            imagesWidget,
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        modification['name'] ??
                                            'Unnamed Modification',
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
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () async {
                                      final result = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditModificationView(
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
                            if (modification['brand'] != null &&
                                modification['brand']
                                    .toString()
                                    .trim()
                                    .isNotEmpty)
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
                                modification['notes']
                                    .toString()
                                    .isNotEmpty)
                              Text(
                                modification['notes'],
                                style: const TextStyle(color: Colors.white70),
                              ),
                            const SizedBox(height: 10),
                            if (modification['installed_myself'] == 1 ||
                                (modification['installed_by'] != null &&
                                    modification['installed_by']
                                        .toString()
                                        .isNotEmpty))
                              Text(
                                modification['installed_myself'] == 1
                                    ? "Self-Installed"
                                    : "Installed by: ${modification['installed_by']}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
