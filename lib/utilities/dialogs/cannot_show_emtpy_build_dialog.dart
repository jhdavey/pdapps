import 'package:flutter/material.dart';
import 'package:pd/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyBuildDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Sharing',
    content: 'You cannot share an empty build!',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}
