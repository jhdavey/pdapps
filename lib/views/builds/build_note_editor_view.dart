// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/build/note/create_note.dart';
import 'package:pd/services/api/build/note/edit_note.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

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
  QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null &&
        widget.note!['note'] != null &&
        widget.note!['note'].toString().trim().isNotEmpty) {
      try {
        final deltaJson = jsonDecode(widget.note!['note']);
        _controller = QuillController(
          document: Document.fromJson(deltaJson),
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController.basic();
      }
    } else {
      _controller = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _insertImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        // Call your uploadImage function (which returns a URL)
        final String imageUrl = await uploadImage(imageFile, context);

        int index = _controller.selection.baseOffset;
        if (index < 0) index = _controller.document.length;

        // Ensure there is a newline before the image embed.
        final String plainText = _controller.document.toPlainText();
        if (index > 0 && plainText[index - 1] != "\n") {
          _controller.replaceText(
            index,
            0,
            "\n",
            TextSelection.collapsed(offset: index + 1),
          );
          index++;
        }

        // Insert the image embed.
        _controller.replaceText(
          index,
          0,
          BlockEmbed.image(imageUrl),
          TextSelection.collapsed(offset: index + 1),
        );
        index++;

        // Insert a newline after the embed.
        _controller.replaceText(
          index,
          0,
          "\n",
          TextSelection.collapsed(offset: index + 1),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image insertion failed: $e')),
        );
      }
    }
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
    setState(() {
      isDeleting = true;
    });
    final success = await deleteNote(
      context: context,
      noteId: widget.note!['id'],
    );
    if (success) {
      Navigator.pop(context, true);
    }
    if (mounted) {
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
                      final shouldDelete =
                          await showDeleteDialog(context, 'note');
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
            Row(
              children: [
                Expanded(child: QuillSimpleToolbar(controller: _controller)),
                IconButton(
                  icon: const Icon(Icons.image),
                  tooltip: 'Insert Image',
                  onPressed: _insertImage,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F242C),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: QuillEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: QuillEditorConfig(
                      placeholder: 'Start writing your notes...',
                      padding: const EdgeInsets.all(8),
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}