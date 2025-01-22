import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pd/services/cloud/cloud_storage_constants.dart';
import 'package:flutter/foundation.dart';

@immutable
class CloudBuild {
  final String documentId;
  final String ownerUserId;
  final String text;
  const CloudBuild({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudBuild.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerUserId = snapshot.data()[ownerUserIdFieldName],
        text = snapshot.data()[buildMake] as String;
}
