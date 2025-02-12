import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pd/views/builds/build_note_view.dart'; // if needed for ManageNotePage

class BuildNotesSection extends StatelessWidget {
  final List<dynamic> notes;
  final int buildId;
  final bool isOwner;
  final VoidCallback reloadBuildData;

  const BuildNotesSection({
    super.key,
    required this.notes,
    required this.buildId,
    required this.isOwner,
    required this.reloadBuildData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1F242C),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with title and add button.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Build Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    // Navigate to the ManageNotePage in "add note" mode.
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageNotePage(
                          buildId: buildId,
                          note: null,
                          reloadBuildData: reloadBuildData,
                        ),
                      ),
                    );
                    if (result == true) {
                      reloadBuildData();
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (notes.isEmpty)
            const Text(
              'No build notes have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...notes.map((note) {
              // Attempt to parse the note's content (stored as a JSON-encoded Delta).
              quill.Document document;
              try {
                final deltaJson = jsonDecode(note['note']);
                document = quill.Document.fromJson(deltaJson);
              } catch (e) {
                // Fallback to a plain text document if parsing fails.
                document = quill.Document()..insert(0, note['note'] ?? '');
              }
              // Create a temporary controller for rendering.
              final controller = quill.QuillController(
                document: document,
                selection: const TextSelection.collapsed(offset: 0),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use AbsorbPointer to render the note as read-only rich text.
                    Expanded(
                      child: AbsorbPointer(
                        child: quill.QuillEditor(
                          controller: controller,
                          focusNode: FocusNode(), // Create a temporary focus node.
                          scrollController: ScrollController(), // Temporary scroll controller.
                        ),
                      ),
                    ),
                    if (isOwner)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageNotePage(
                                buildId: buildId,
                                note: note,
                                reloadBuildData: reloadBuildData,
                              ),
                            ),
                          );
                          if (result == true) {
                            reloadBuildData();
                          }
                        },
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
