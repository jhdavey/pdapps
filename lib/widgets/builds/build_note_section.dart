import 'package:flutter/material.dart';
import 'package:pd/views/builds/notes/create_note_view.dart';
import 'package:pd/views/builds/notes/edit_note_view.dart';

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
        color: Colors.grey[900],
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
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateNoteView(buildId: buildId),
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
          // Display a message if there are no notes, otherwise list them
          if (notes.isEmpty)
            const Text(
              'No build notes have been added yet.',
              style: TextStyle(color: Colors.white70),
            )
          else
            ...notes.map((note) {
              return ListTile(
                title: Text(
                  note['note'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: isOwner
                    ? IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditNoteView(
                                buildId: buildId,
                                note: note,
                              ),
                            ),
                          );
                          if (result == true) {
                            reloadBuildData();
                          }
                        },
                      )
                    : null,
              );
            })
        ],
      ),
    );
  }
}
