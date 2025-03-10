// linkable_quill_viewer.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';

class QuillViewer extends StatelessWidget {
  final quill.Document document;

  const QuillViewer({Key? key, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final delta = document.toDelta();
    List<InlineSpan> spans = [];
    for (var op in delta.toList()) {
      var insert = op.data;
      Map<String, dynamic> attributes = op.attributes ?? {};
      if (insert is String) {
        if (attributes.containsKey('link')) {
          String link = attributes['link'];
          spans.add(
            TextSpan(
              text: insert,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final uri = Uri.parse(link);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not launch URL')),
                    );
                  }
                },
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: insert,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
      }
      // (Optional) Handle non-text inserts (like images) here if needed.
    }
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
