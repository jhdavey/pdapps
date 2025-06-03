import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/show_image_dialog.dart';
import 'package:pd/utilities/dialogs/video_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget buildAdditionalMediaSection(
  Map<String, dynamic> build, {
  required Future<void> Function() reloadBuildData,
  required bool isOwner,
}) {
  final dynamic rawMedia = build['additional_media'] ??
      (build['additional_images'] is String
          ? jsonDecode(build['additional_images'])
          : build['additional_images']);

  // Convert rawMedia into a list of maps.
  final List<Map<String, dynamic>> mediaList = rawMedia is List
      ? rawMedia
          .map<Map<String, dynamic>>((item) {
            if (item is String) {
              return {
                'id': null,
                'url': item,
                'type': 'image',
                'caption': '',
              };
            } else if (item is Map) {
              final mapItem = Map<String, dynamic>.from(item);
              mapItem.putIfAbsent('type', () => 'image');
              mapItem.putIfAbsent('caption', () => '');
              mapItem.putIfAbsent('id', () => null);
              return mapItem;
            } else {
              return {};
            }
          })
          .where((element) => element.isNotEmpty)
          .toList()
      : [];

  // Reverse the media order so that the most recently added media shows up first.
  final List<Map<String, dynamic>> reversedMediaList =
      mediaList.reversed.toList();

  return Builder(
    builder: (BuildContext outerContext) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isOwner) const SizedBox.shrink(),
              ],
            ),
          ),
          reversedMediaList.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "No additional featured images added yet.",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                )
              : SizedBox(
                  height: 300,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: reversedMediaList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final media = reversedMediaList[index];
                      final String url = media['url'];
                      // Determine if the file is a video.
                      final bool isVideo = media['type'] == 'video' ||
                          url.toLowerCase().endsWith('.mp4') ||
                          url.toLowerCase().endsWith('.mov');

                      final Widget mediaWidget;
                      if (isVideo) {
                        mediaWidget = GestureDetector(
                          onTap: () => showVideoDialog(
                            context,
                            reversedMediaList,
                            index,
                            isOwner: isOwner,
                            reloadBuildData: reloadBuildData,
                          ),
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 40,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // For images, use CachedNetworkImage.
                        mediaWidget = GestureDetector(
                          onTap: () => showImageDialog(
                            context,
                            reversedMediaList,
                            index,
                            isOwner: isOwner,
                            reloadBuildData: reloadBuildData,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 300,
                              height: 300,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 300,
                                height: 300,
                                color: Colors.black12,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          mediaWidget,
                          // Caption overlay (if exists)
                          if ((media['caption'] as String).isNotEmpty)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 40,
                                color: Colors.black.withOpacity(0.8),
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  (media['caption'] as String).length > 30
                                      ? "${(media['caption'] as String).substring(0, 30)}..."
                                      : media['caption'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
        ],
      );
    },
  );
}
