import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pd/services/api/auth/auth_service.dart';

Future<String?> updateBuildOwnership(
    BuildContext context, Map<String, dynamic> buildData) async {
  final currentUser =
      await RepositoryProvider.of<ApiAuthService>(context).getCurrentUser();

  if (currentUser != null) {
    final currentUserId = currentUser.id.toString();
    final buildUser = buildData['user'] as Map<String, dynamic>?;
    if (buildUser != null && buildUser.containsKey('id')) {
      final buildUserId = buildUser['id'].toString();
      buildData['is_owner'] = buildUserId == currentUserId;
    } else {
      buildData['is_owner'] = false;
    }
    return currentUserId;
  }
  return null;
}
