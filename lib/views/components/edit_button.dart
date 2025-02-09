import 'package:flutter/material.dart';

class EditIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isSubmitting;
  final Color iconColor;

  const EditIconButton({
    super.key,
    required this.onPressed,
    this.isSubmitting = false,
    this.iconColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      color: iconColor,
      onPressed: isSubmitting ? null : onPressed,
      tooltip: "Edit",
    );
  }
}
