import 'package:flutter/material.dart';

class TagChipList extends StatelessWidget {
  final List<dynamic> tags;

  const TagChipList({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, idx) {
          final tag = tags[idx];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/tag-view', arguments: {'tag': tag});
            },
            child: Chip(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              label: Container(
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  tag['name'] ?? 'Tag',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
