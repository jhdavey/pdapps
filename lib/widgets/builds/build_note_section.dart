import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pd/utilities/dialogs/maintenance/maintenance_record_dialog.dart';
import 'package:pd/views/builds/build_note_editor_view.dart';
import 'package:pd/widgets/quill_viewer.dart';
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Build Notes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Wrap the icon and text in a GestureDetector for a single tap event.
                  GestureDetector(
                    onTap: () {
                      showMaintenanceRecordsDialog(context, buildId,
                          isOwner: isOwner);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.build, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        const Text(
                          "Maintenance",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Right group: "Add" icon (if owner).
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
          // The scrollable area for notes.
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: notes.isEmpty
                    ? [
                        Text(
                          'No build notes have been added yet.',
                          style: TextStyle(color: Colors.white70),
                        )
                      ]
                    : notes.reversed.toList().asMap().entries.map((entry) {
                        final int index = entry.key;
                        final note = entry.value;
                        quill.Document document;
                        try {
                          final deltaJson = jsonDecode(note['note']);
                          document = quill.Document.fromJson(deltaJson);
                        } catch (e) {
                          document = quill.Document()
                            ..insert(0, note['note'] ?? '');
                        }
                        Widget noteWidget = QuillViewer(document: document);

                        final String updatedAtRaw = note['updated_at'] ?? '';
                        Widget footerWidget = Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UpdatedDateTimeWidget(updatedAtRaw: updatedAtRaw),
                            if (isOwner)
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.white, size: 16),
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            noteWidget,
                            footerWidget,
                            if (index != notes.length - 1)
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                          ],
                        );
                      }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
