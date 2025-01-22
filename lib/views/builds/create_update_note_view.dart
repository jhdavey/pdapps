// ignore_for_file: library_private_types_in_public_api, avoid_types_as_parameter_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pd/services/auth/auth_service.dart';
import 'package:pd/services/cloud/cloud_build.dart';
import 'package:pd/services/cloud/firebase_cloud_storage.dart';
import 'package:pd/utilities/dialogs/cannot_show_emtpy_build_dialog.dart';
import 'package:pd/utilities/generics/get_arguments.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateBuildView extends StatefulWidget {
  const CreateUpdateBuildView({super.key});

  @override
  _CreateUpdateBuildViewState createState() => _CreateUpdateBuildViewState();
}

class _CreateUpdateBuildViewState extends State<CreateUpdateBuildView> {
  CloudBuild? _build;
  late final FirebaseCloudStorage _buildsService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _buildsService = FirebaseCloudStorage();
    _textController = TextEditingController();
    super.initState();
  }

  void _textControllerListener() async {
    final build = _build;
    if (build == null) {
      return;
    }
    final text = _textController.text;
    await _buildsService.updateBuild(
      documentId: build.documentId,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudBuild> createOrGetExistingBuild(BuildContext) async {
    final widgetBuild = context.getArgument<CloudBuild>();

    if (widgetBuild != null) {
      _build = widgetBuild;
      _textController.text = widgetBuild.text;
      return widgetBuild;
    }

    final existingBuild = _build;
    if (existingBuild != null) {
      return existingBuild;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newBuild = await _buildsService.createNewBuild(ownerUserId: userId);
    _build = newBuild;
    return newBuild;
  }

  void _deleteBuildIfMakeIsEmpty() {
    final build = _build;
    if (_textController.text.isEmpty && build != null) {
      _buildsService.deleteBuild(documentId: build.documentId);
    }
  }

  void _saveNBuildIfMakeNotEmpty() async {
    final build = _build;
    final text = _textController.text;
    if (build != null && text.isNotEmpty) {
      await _buildsService.updateBuild(
        documentId: build.documentId,
        text: text,
      );
    }
  }

  @override
  void dispose() {
    _deleteBuildIfMakeIsEmpty();
    _saveNBuildIfMakeNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Build'),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              if (_build == null || text.isEmpty) {
                await showCannotShareEmptyBuildDialog(context);
              } else {
                Share.share(text);
              }
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingBuild(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _setupTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Start typing your build...',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
