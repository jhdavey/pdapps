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
    child: Card(
      color: const Color(0xFF1F242C),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...filteredData.map((data) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                )),
          ],
        ),
      ),
    ),
  );
}

