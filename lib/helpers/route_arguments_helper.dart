import 'package:flutter/material.dart';

Map<String, dynamic> getRouteArguments(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  if (args != null && args is Map<String, dynamic>) {
    if (args.containsKey('build')) {
      final build = Map<String, dynamic>.from(args['build'] as Map);
      if (args.containsKey('modificationsByCategory')) {
        build['modificationsByCategory'] = args['modificationsByCategory'];
      }
      if (args.containsKey('notes')) {
        build['notes'] = args['notes'];
      }
      if (args.containsKey('comments')) {
        build['comments'] = args['comments'];
      }
      return build;
    } else {
      return Map<String, dynamic>.from(args);
    }
  }
  return <String, dynamic>{};
}
