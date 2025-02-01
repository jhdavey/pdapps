  import 'package:flutter/material.dart';

Widget buildTags(Map<String, dynamic> build) {
    final List tagList = build['tags'] is List ? build['tags'] : [];
    if (tagList.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tagList.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, idx) {
          final tag = tagList[idx];
          return GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed('/tag-view', arguments: {'tag': tag});
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