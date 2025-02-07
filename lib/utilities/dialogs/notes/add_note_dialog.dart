// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:pd/services/api/build/note/create_note.dart';
import 'package:pd/utilities/dialogs/create_dialog.dart';

Future<void> showAddNoteDialog(
  BuildContext context,
  int buildId,
  VoidCallback reloadBuildData,
) async {
  await showCreateDialog(
    context: context,
    title: 'Add Note',
    label: 'Note',
    onSubmit: (noteText) async {
      final success = await submitNote(
        context: context,
        buildId: buildId,
        note: noteText,
      );
      if (success) {
        reloadBuildData();
      }
    },
  );
}
