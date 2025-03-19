import 'package:flutter/material.dart';

class RefreshableContent extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final ScrollController? controller; // new optional controller

  const RefreshableContent({
    Key? key,
    required this.onRefresh,
    required this.child,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: controller, // pass the controller if provided
        physics: const AlwaysScrollableScrollPhysics(),
        child: child,
      ),
    );
  }
}
