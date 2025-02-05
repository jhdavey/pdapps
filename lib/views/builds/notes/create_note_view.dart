// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/services/api/build/note/create_note.dart';

class CreateNoteView extends StatefulWidget {
  final int buildId;
  const CreateNoteView({super.key, required this.buildId});

  @override
  _CreateNoteViewState createState() => _CreateNoteViewState();
}

class _CreateNoteViewState extends State<CreateNoteView> {
  final _formKey = GlobalKey<FormState>();
  String? _note;
  bool _isSubmitting = false;

Future<void> _submitNote() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final success = await submitNote(
      context: context,
      buildId: widget.buildId,
      note: _note ?? '',
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
        title: const Text('Create Note'),
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
                onSaved: (value) => _note = value,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a note' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitNote,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
