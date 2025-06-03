// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/post/post_controller.dart';

class LikeButton extends StatefulWidget {
  final int postId;
  final int initialLikeCount;
  final bool initialIsLiked;

  const LikeButton({
    super.key,
    required this.postId,
    required this.initialLikeCount,
    required this.initialIsLiked,
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialIsLiked;
    likeCount = widget.initialLikeCount;
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLikeCount != widget.initialLikeCount ||
        oldWidget.initialIsLiked != widget.initialIsLiked) {
      setState(() {
        likeCount = widget.initialLikeCount;
        isLiked = widget.initialIsLiked;
      });
    }
  }

  Widget _buildLikedIcon() {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Colors.pink, Colors.red],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: const Icon(
        Icons.favorite,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildUnlikedIcon() {
    return const Icon(Icons.favorite_border, color: Colors.white70);
  }

  Future<void> _toggleLike() async {
    bool previousIsLiked = isLiked;
    int previousLikeCount = likeCount;

    setState(() {
      if (isLiked) {
        likeCount = (likeCount > 0) ? likeCount - 1 : 0;
        isLiked = false;
      } else {
        likeCount++;
        isLiked = true;
      }
    });

    try {
      bool success;
      if (isLiked) {
        success = await PostService().likePost(widget.postId);
      } else {
        success = await PostService().unlikePost(widget.postId);
      }

      if (!success) {
        setState(() {
          isLiked = previousIsLiked;
          likeCount = previousLikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update like status.")),
        );
      }
    } catch (e) {
      setState(() {
        isLiked = previousIsLiked;
        likeCount = previousLikeCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating like: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          likeCount.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
        IconButton(
          onPressed: _toggleLike,
          icon: isLiked ? _buildLikedIcon() : _buildUnlikedIcon(),
        ),
      ],
    );
  }
}
