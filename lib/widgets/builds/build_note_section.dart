import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/notes/manage_note_dialog.dart';

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
                    final result = await showManageNoteDialog(
                        context, buildId, null, reloadBuildData);
                    if (result == true) {
                      reloadBuildData();
                    }
                  },
                ),
            ],
          ),
          if (notes.isEmpty)
            const Text(
              'No build notes have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...notes.map((note) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note['note'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (isOwner)
                    IconButton(
                      icon: const Icon(Icons.edit,
                          color: Colors.white, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final result = await showManageNoteDialog(
                            context, buildId, note, reloadBuildData);
                        if (result == true) {
                          reloadBuildData();
                        }
                      },
                    ),
                ],
              );
            }),
        ],
      ),
    );
  }
}
