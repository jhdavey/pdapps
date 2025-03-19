import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDialog extends StatefulWidget {
  final List<Map<String, dynamic>> media;
  final int initialIndex;
  final bool isOwner;
  final Future<void> Function() reloadBuildData;

  const VideoDialog({
    super.key,
    required this.media,
    required this.initialIndex,
    this.isOwner = false,
    required this.reloadBuildData,
  });

  @override
  _VideoDialogState createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  late VideoPlayerController _controller;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initializeVideo();
  }

  void _initializeVideo() {
    final String url = widget.media[currentIndex]['url'];
    _controller = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Formats a Duration to mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1F242C),
      insetPadding: const EdgeInsets.all(16),
      child: _controller.value.isInitialized
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Video player
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                // Progress indicator with scrubbing enabled.
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                    backgroundColor: Colors.black,
                  ),
                ),
                // Display current position and total duration.
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(_controller.value.position),
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        formatDuration(_controller.value.duration),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Playback controls and close button.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}

/// Helper function to show the video dialog.
void showVideoDialog(
  BuildContext context,
  List<Map<String, dynamic>> media,
  int initialIndex, {
  bool isOwner = false,
  required Future<void> Function() reloadBuildData,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return VideoDialog(
        media: media,
        initialIndex: initialIndex,
        isOwner: isOwner,
        reloadBuildData: reloadBuildData,
      );
    },
  );
}
