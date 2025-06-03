import 'package:flutter/material.dart';

Widget buildSection({
  required String title,
  required List<Map<String, dynamic>> dataPoints,
}) {
  final filteredData =
      dataPoints.where((data) => data['value'] != null).toList();
  if (filteredData.isEmpty) {
    return const SizedBox();
  }
  return SizedBox(
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...filteredData.map((data) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${data['label']}: ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: "${data['value']}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  );
}
