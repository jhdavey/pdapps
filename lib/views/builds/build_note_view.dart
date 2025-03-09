// manage_note_page.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pd/services/api/build/note/create_note.dart';
import 'package:pd/services/api/build/note/edit_note.dart';
import 'package:pd/utilities/dialogs/generic_dialog.dart';

class ManageNotePage extends StatefulWidget {
  final int buildId;
  final Map<String, dynamic>? note;
  final VoidCallback reloadBuildData;

  const ManageNotePage({
    super.key,
    required this.buildId,
    required this.note,
    required this.reloadBuildData,
  });

  @override
  State<ManageNotePage> createState() => _ManageNotePageState();
}

class _ManageNotePageState extends State<ManageNotePage> {
  late final quill.QuillController _controller;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null &&
        widget.note!['note'] != null &&
        widget.note!['note'].toString().trim().isNotEmpty) {
      try {
        final deltaJson = jsonDecode(widget.note!['note']);
        _controller = quill.QuillController(
          document: quill.Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submitNote() async {
    final delta = _controller.document.toDelta();
    final noteContent = jsonEncode(delta.toJson());
    bool success = false;
    if (widget.note == null) {
      // Adding a new note.
      success = await submitNote(
        context: context,
        buildId: widget.buildId,
        note: noteContent,
      );
    } else {
      // Updating an existing note.
      success = await updateNote(
        context: context,
        noteId: widget.note!['id'],
        note: noteContent,
      );
    }
    if (success) {
      widget.reloadBuildData();
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note == null) return;
    setState(() {
      isDeleting = true;
    });
    final success = await deleteNote(
      context: context,
      noteId: widget.note!['id'],
    );
    if (success) {
      widget.reloadBuildData();
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewNote = widget.note == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNewNote ? 'Add Note' : 'Manage Note'),
        actions: [
          if (!isNewNote)
            IconButton(
              icon: isDeleting
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.delete, color: Colors.red),
              onPressed: isDeleting
                  ? null
                  : () async {
                      final shouldDelete = await showDeleteDialog(context, 'note');
                      if (shouldDelete) {
                        await _deleteNote();
                      }
                    },
            ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              child: quill.QuillSimpleToolbar(controller: _controller),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                height: min(300, 500),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F242C),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: quill.QuillEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context, String itemType) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this $itemType?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
