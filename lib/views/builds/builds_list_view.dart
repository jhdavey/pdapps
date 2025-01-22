import 'package:flutter/material.dart';
import 'package:pd/services/cloud/cloud_build.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

typedef BuildCallback = void Function(CloudBuild build);

class BuildListView extends StatelessWidget {
  final Iterable<CloudBuild> builds;
  final BuildCallback onDeleteBuild;
  final BuildCallback onTap;

  const BuildListView.BuildListView({
    super.key,
    required this.builds,
    required this.onDeleteBuild,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: builds.length,
      itemBuilder: (context, index) {
        final build = builds.elementAt(index);
        return ListTile(
          onTap: () {
            onTap(build);
          },
          title: Text(build.text,
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteBuild(build);
              }
            },
            icon: Icon(Icons.delete),
          ),
        );
      },
    );
  }
}
