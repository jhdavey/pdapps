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
    if (modificationsByCategory.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with "Modifications" and plus icon (only if owner)
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
            const SizedBox(height: 10),
            // For each category, display an ExpansionTile
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
                                      buildId: buildId,
                                      modification: modification,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  reloadBuildData();
                                }
                              },
                            )
                          : null,
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brand: ${modification['brand'] ?? 'Unknown'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          if (modification['price'] != null)
                            Text(
                              'Price: \$${modification['price']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
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
            })
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
      );
    }
  }
}
