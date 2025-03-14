// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/favorite_controller.dart';

class FavoriteButton extends StatefulWidget {
  final int buildId;
  final int initialFavoriteCount;
  final bool initialIsFavorited;

  const FavoriteButton({
    super.key,
    required this.buildId,
    required this.initialFavoriteCount,
    required this.initialIsFavorited,
  });

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isFavorited;
  late int favoriteCount;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.initialIsFavorited;
    favoriteCount = widget.initialFavoriteCount;
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFavoriteCount != widget.initialFavoriteCount ||
        oldWidget.initialIsFavorited != widget.initialIsFavorited) {
      setState(() {
        favoriteCount = widget.initialFavoriteCount;
        isFavorited = widget.initialIsFavorited;
      });
    }
  }

  Widget _buildFavoritedIcon() {
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
        color: Colors.white,
      ),
    );
  }

  Widget _buildUnfavoritedIcon() {
    return const Icon(Icons.favorite_border, color: Colors.white);
  }

  Future<void> _toggleFavorite() async {
    // Save previous state for rollback.
    bool previousIsFavorited = isFavorited;
    int previousFavoriteCount = favoriteCount;

    setState(() {
      if (isFavorited) {
        favoriteCount = (favoriteCount > 0) ? favoriteCount - 1 : 0;
        isFavorited = false;
      } else {
        favoriteCount++;
        isFavorited = true;
      }
    });

    try {
      bool success;
      if (isFavorited) {
        success = await addFavorite(
          context: context,
          buildId: widget.buildId,
        );
      } else {
        success = await removeFavorite(
          context: context,
          buildId: widget.buildId,
        );
      }
      if (!success) {
        // Rollback on failure.
        setState(() {
          isFavorited = previousIsFavorited;
          favoriteCount = previousFavoriteCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update favorite status.")),
        );
      }
    } catch (e) {
      setState(() {
        isFavorited = previousIsFavorited;
        favoriteCount = previousFavoriteCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating favorite: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          favoriteCount.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        IconButton(
          onPressed: _toggleFavorite,
          icon: isFavorited ? _buildFavoritedIcon() : _buildUnfavoritedIcon(),
        ),
      ],
    );
  }
}
