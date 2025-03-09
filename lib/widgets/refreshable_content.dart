import 'package:flutter/material.dart';

class RefreshableContent extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const RefreshableContent({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}
