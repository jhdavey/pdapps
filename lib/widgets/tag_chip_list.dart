import 'package:flutter/material.dart';

class TagChipList extends StatelessWidget {
  final List<dynamic> tags;
  // Default alignment is right.
  final MainAxisAlignment alignment;

  const TagChipList({
    Key? key,
    required this.tags,
    this.alignment = MainAxisAlignment.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    final children = tags.map((tag) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/tag-view', arguments: {'tag': tag});
          },
          child: Chip(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            label: Text(
              tag['name'] ?? 'Tag',
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // Force the Row to be at least as wide as the available width.
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: alignment,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
