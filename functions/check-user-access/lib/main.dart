import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Initializing Appwrite Services...");
  final databases = Databases(client);
  // final users = Users(client);

  final databaseId = Platform.environment['DATABASE'] ?? '';
  final userCollectionId = Platform.environment['USER_COLLECTION'] ?? '';
  // final logsId = Platform.environment['LOGS_COLLECTION'] ?? '';

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    final userData = await databases.getDocument(
      databaseId: databaseId,
      collectionId: userCollectionId,
      documentId: body['id'],
    );

    return context.res.json({'user': userData.data});
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could fetch users permissions',
      'error': e.message,
    });
  }
}
