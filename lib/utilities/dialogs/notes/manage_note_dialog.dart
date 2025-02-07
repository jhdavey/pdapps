// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/note/create_note.dart';
import 'package:pd/services/api/build/note/edit_note.dart';
import 'package:pd/utilities/dialogs/manage_dialog.dart';

Future<bool> showManageNoteDialog(
  BuildContext context,
  int buildId,
  Map<String, dynamic>? note,
  VoidCallback reloadBuildData,
) async {
  bool success = false;
  bool isNewNote = note == null;

  await showManageDialog(
    context: context,
    title: isNewNote ? 'Add Note' : 'Manage Note',
    label: 'Note',
    initialValue: note?['note'] ?? '',
    onDelete: isNewNote
        ? () async => false
        : () async {
            success = await deleteNote(context: context, noteId: note['id']);
            if (success) {
              reloadBuildData();
            }
            return success;
          },
    onUpdate: (updatedNote) async {
      if (updatedNote.trim().isNotEmpty) {
        if (isNewNote) {
          success = await submitNote(
            context: context,
            buildId: buildId,
            note: updatedNote.trim(),
          );
        } else {
          success = await updateNote(
            context: context,
            noteId: note['id'],
            note: updatedNote.trim(),
          );
        }

        if (success) {
          reloadBuildData();
        }
      }
    },
  );

  return success;
}
