// quill_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class QuillViewer extends StatelessWidget {
  final Document document;

  const QuillViewer({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    // Create a new controller for viewing (readOnly).
    final QuillController viewerController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return IgnorePointer(
      child: QuillEditor(
        controller: viewerController,
        focusNode: FocusNode(),
        scrollController: ScrollController(),
        config: QuillEditorConfig(
          placeholder: '',
          padding: EdgeInsets.zero,
          embedBuilders: FlutterQuillEmbeds.editorBuilders(),
        ),
      ),
    );
  }
}
