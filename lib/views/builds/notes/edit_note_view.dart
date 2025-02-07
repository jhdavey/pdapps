// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/note/edit_note.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class EditNoteView extends StatefulWidget {
  final int buildId;
  final Map<String, dynamic> note;

  const EditNoteView({super.key, required this.buildId, required this.note});

  @override
  _EditNoteViewState createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView> {
  final _formKey = GlobalKey<FormState>();
  late String _note;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note['note'] ?? '';
  }

  Future<void> _submitNote() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final success = await updateNote(
      context: context,
      noteId: widget.note['id'],
      note: _note,
    );

    if (success) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteNote() async {
    final confirm = await showDeleteDialog(context);
    if (!confirm) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await deleteNote(
      context: context,
      noteId: widget.note['id'],
    );

    if (success) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isSubmitting ? null : _deleteNote,
            color: const Color(0xFFED1C24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Note',
                  border: OutlineInputBorder(),
                ),
                maxLines: 8,
                initialValue: _note,
                onSaved: (value) => _note = value ?? '',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a note' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNote,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
