import 'package:flutter/material.dart';

class TagChipList extends StatelessWidget {
  final List<dynamic> tags;
  final WrapAlignment alignment;

  const TagChipList({
    super.key,
    required this.tags,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final children = tags.map((tag) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/tag-view', arguments: {'tag': tag});
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: alignment == WrapAlignment.center
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: children,
            ),
          ),
        );
      },
    );
  }
}
