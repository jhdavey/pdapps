import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pd/services/cloud/cloud_build.dart';
import 'package:pd/services/cloud/cloud_storage_constants.dart';
import 'package:pd/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final builds = FirebaseFirestore.instance.collection('builds');

  Future<void> deleteBuild({required String documentId}) async {
    try {
      await builds.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteBuild();
    }
  }

  Future<void> updateBuild({
    required String documentId,
    required String text,
  }) async {
    try {
      await builds.doc(documentId).update({buildMake: text});
    } catch (e) {
      throw CouldNotUpdateBuild();
    }
  }

  Stream<Iterable<CloudBuild>> allBuilds({required String ownerUserId}) {
    final allBuilds = builds
        .where(ownerUserIdFieldName, isEqualTo: ownerUserId)
        .snapshots()
        .map((event) => event.docs.map((doc) => CloudBuild.fromSnapshot(doc)));
    return allBuilds;
  }

  Future<CloudBuild> createNewBuild({required String ownerUserId}) async {
    final document = await builds.add({
      ownerUserIdFieldName: ownerUserId,
      buildMake: '',
    });
    final fetchedBuild = await document.get();
    return CloudBuild(
      documentId: fetchedBuild.id,
      ownerUserId: ownerUserId,
      text: '',
    );
  }

  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;
}
