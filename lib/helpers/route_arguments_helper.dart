import 'package:flutter/material.dart';

Map<String, dynamic> getRouteArguments(BuildContext context) {
  final args = ModalRoute.of(context)?.settings.arguments;

  if (args != null) {
    if (args is Map<String, dynamic>) {
      if (args.containsKey('build')) {
        final dynamic buildArg = args['build'];
        if (buildArg is Map<String, dynamic>) {
          return buildArg;
        } else if (buildArg is List && buildArg.isNotEmpty && buildArg[0] is Map<String, dynamic>) {
          return buildArg[0];
        } else {
          throw Exception("Invalid 'build' argument format.");
        }
      } else {
        return Map<String, dynamic>.from(args);
      }
    } 
    else if (args is List && args.isNotEmpty && args[0] is Map<String, dynamic>) {
      return args[0];
    }
  }
  return <String, dynamic>{};
}
