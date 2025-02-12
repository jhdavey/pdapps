// build_files_section.dart
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pd/services/api/build/build_file_controller.dart';

class BuildFilesSection extends StatefulWidget {
  final Map<String, dynamic> build;
  final bool isOwner;
  final VoidCallback? refreshBuild;

  const BuildFilesSection({
    super.key,
    required this.build,
    required this.isOwner,
    this.refreshBuild,
  });

  @override
  _BuildFilesSectionState createState() => _BuildFilesSectionState();
}

class _BuildFilesSectionState extends State<BuildFilesSection> {
  bool isUploading = false;

  Future<void> _downloadFile(dynamic file) async {
    final String fileUrl = file['download_url'] ??
        file['url'] ??
        (file.containsKey('path')
            ? "https://passiondrivenbuilds.com/storage/${file['path']}"
            : "");
    if (fileUrl.isNotEmpty) {
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not launch file URL.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File URL is missing.")),
      );
    }
  }

  Future<void> _handleUpload() async {
    setState(() {
      isUploading = true;
    });
    final uploadedFile = await uploadFile(
      context,
      buildId: widget.build['id'].toString(),
    );
    if (uploadedFile != null) {
      setState(() {
        if (widget.build['files'] == null) {
          widget.build['files'] = [];
        }
        widget.build['files'].add(uploadedFile);
      });
      if (widget.refreshBuild != null) widget.refreshBuild!();
    }
    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> files = widget.build['files'] ?? [];
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Build Files",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.isOwner)
                IconButton(
                  icon: isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add, color: Colors.white),
                  onPressed: isUploading ? null : _handleUpload,
                ),
            ],
          ),
          // Files list.
          files.isNotEmpty
              ? Column(
                  children: files.map((file) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // File name.
                          Expanded(
                            child: Text(
                              file['name'] ?? "Unnamed file",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          // Download button.
                          IconButton(
                            icon:
                                const Icon(Icons.download, color: Colors.blue),
                            onPressed: () => _downloadFile(file),
                          ),
                          // Delete button (only for build owner).
                          if (widget.isOwner)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                bool success = await deleteFile(
                                  context,
                                  fileId: file['id'].toString(),
                                );
                                if (success) {
                                  setState(() {
                                    widget.build['files'].removeWhere(
                                        (element) =>
                                            element['id'].toString() ==
                                            file['id'].toString());
                                  });
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : const Text(
                  "No files for this build yet...",
                  style: TextStyle(color: Colors.white),
                ),
        ],
      ),
    );
  }
}
