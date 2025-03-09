import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpdatedDateTimeWidget extends StatelessWidget {
  final String updatedAtRaw;

  const UpdatedDateTimeWidget({
    Key? key,
    required this.updatedAtRaw,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime updatedAtDateTime = DateTime.tryParse(updatedAtRaw) ?? DateTime.now();
    final formattedUpdatedAt = DateFormat("MMM d, yyyy 'at' h:mma")
        .format(updatedAtDateTime)
        .toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        'Updated: $formattedUpdatedAt',
        style: const TextStyle(
          fontSize: 12,
          fontStyle: FontStyle.italic,
          color: Colors.white70,
        ),
      ),
    );
  }
}
