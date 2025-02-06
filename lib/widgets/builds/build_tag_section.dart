import 'package:flutter/material.dart';

class BuildTags extends StatelessWidget {
  final Map<String, dynamic> buildData;

  const BuildTags({
    super.key,
    required this.buildData,
  });

  @override
  Widget build(BuildContext context) {
    final List tagList = buildData['tags'] is List ? buildData['tags'] : [];
    if (tagList.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tagList.map<Widget>((tag) {
        return Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/tag-view',
                arguments: {'tag': tag},
              );
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
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.0,
                  ),
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
