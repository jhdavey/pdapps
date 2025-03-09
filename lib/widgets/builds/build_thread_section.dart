import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pd/views/builds/build_note_view.dart';
import 'package:pd/widgets/update_datetime.dart';

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
                'Build Thread',
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
            ...notes.asMap().entries.map((entry) {
              final int index = entry.key;
              final note = entry.value;
              quill.Document document;
              try {
                final deltaJson = jsonDecode(note['note']);
                document = quill.Document.fromJson(deltaJson);
              } catch (e) {
                document = quill.Document()..insert(0, note['note'] ?? '');
              }
              final controller = quill.QuillController(
                document: document,
                selection: const TextSelection.collapsed(offset: 0),
              );
              // Note content without the edit button.
              Widget noteWidget = Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: AbsorbPointer(
                  child: quill.QuillEditor(
                    controller: controller,
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                  ),
                ),
              );

              final String updatedAtRaw = note['updated_at'] ?? '';
              // Footer row with updated date/time and edit button at the right.
              Widget footerWidget = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  UpdatedDateTimeWidget(updatedAtRaw: updatedAtRaw),
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
              );

              if (index != notes.length - 1) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noteWidget,
                    footerWidget,
                    const Divider(
                      thickness: 1,
                      color: Colors.white,
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    noteWidget,
                    footerWidget,
                  ],
                );
              }
            })
        ],
      ),
    );
  }
}
