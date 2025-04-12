import 'dart:async';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

// ignore: constant_identifier_names
const INACTIVE_THRESHOLD_MS = 2 * 60 * 1000;
// ignore: constant_identifier_names
const ONLINE_STATUS = "67bf07de00139dce8f0e";
// ignore: constant_identifier_names
const OFFLINE_STATUS = '67bf07e20026ced1dce5';

Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Initializing Appwrite Services...");
  final databases = Databases(client);

  final databaseId = Platform.environment['DATABASE'] ?? '';
  final activityStatusId =
      Platform.environment['ACTIVITY_STATUS_COLLECTION'] ?? '';

  try {
    context.log('Fetching Activity Status Collections...');
    final response = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: activityStatusId,
      queries: [Query.equal('status', ONLINE_STATUS)],
    );

    if (response.total == 0) {
      return context.res
          .json({'mesage': "No users status needs to be modified"});
    }

    final now = DateTime.now();
    List<Future<Document>> promises = [];

    context.log('Checking Users Last Activity Status...');
    for (final user in response.documents) {
      final lastActivityTime =
          DateTime.parse(user.data['last_activity']).millisecondsSinceEpoch;

      final timeDiff = now
          .difference(DateTime.fromMillisecondsSinceEpoch(lastActivityTime))
          .inMilliseconds;

      if (timeDiff > INACTIVE_THRESHOLD_MS) {
        promises.add(
          databases.updateDocument(
            databaseId: databaseId,
            collectionId: activityStatusId,
            documentId: user.$id,
            data: {'status': OFFLINE_STATUS},
          ),
        );
      }
    }

    if (promises.isNotEmpty) {
      await Future.wait(promises);
    }

    return context.res
        .json({'message': 'Modified ${promises.length} users status'});
  } on AppwriteException catch (e) {
    context.error(
      "Ohh ohh, something went wrong: ${e.message}",
    );
    return context.res.json({'error_message': e.message});
  }
}
