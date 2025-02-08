// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/follower_controller.dart';

Future<void> toggleFollowHelper({
  required BuildContext context,
  required int profileUserId,
  required bool currentFollowStatus,
  required void Function(bool newFollowStatus,
          Future<List<dynamic>> newFollowers, Future<List<dynamic>> newFollowing)
      onSuccess,
}) async {
  try {
    final success = await toggleFollow(
      context: context,
      profileUserId: profileUserId,
      isFollowing: currentFollowStatus,
    );
    if (success) {
      onSuccess(
        !currentFollowStatus,
        fetchFollowers(context: context, userId: profileUserId),
        fetchFollowing(context: context, userId: profileUserId),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Error: $e')));
  }
}
