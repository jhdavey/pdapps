import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context, String itemType) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this $itemType?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
