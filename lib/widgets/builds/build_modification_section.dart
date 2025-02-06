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

    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
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
                        builder: (context) =>
                            CreateModificationView(buildId: buildId),
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
          if (hasModifications)
            ...modificationsByCategory.entries.map((entry) {
              final String category = entry.key;
              final List<dynamic> mods = entry.value as List<dynamic>;
              return Theme(
                data: ThemeData(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  backgroundColor: Color(0xFF1F242C),
                  collapsedBackgroundColor: Color(0xFF1F242C),
                  title: Text(
                    category,
                    style: const TextStyle(color: Colors.white),
                  ),
                  children: mods.map((modification) {
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.white, width: 1),
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          modification['name'] ?? 'Unnamed Modification',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isOwner
                            ? IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.white),
                                onPressed: () async {
                                  final result = await Navigator.push(
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
                      ),
                    );
                  }).toList(),
                ),
              );
            })
          else
            Text(
              'No modifications have been added yet.',
              style: TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}
