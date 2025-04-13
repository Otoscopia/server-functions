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
  final storage = Storage(client);

  final databaseId = Platform.environment['APPWRITE_DATABASE'] ?? '';
  final logsId = Platform.environment['APPWRITE_LOGS_COLLECTION'] ?? '';

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    context.log('Fetching Buckets...');
    final response = await storage.listBuckets();

    context.log('Converting response to readable buckets...');
    final buckets = response.buckets
        .map((bucket) => {
              'id': bucket.$id,
              'name': bucket.name,
              'allowed_files': bucket.allowedFileExtensions,
            })
        .toList();

    context.log('Logging user data');

    await databases.createDocument(
        databaseId: databaseId,
        collectionId: logsId,
        documentId: ID.unique(),
        data: {
          'user': body['user'],
          'event': 'get.function.bucket-ids',
          'location': body['location'],
          'ip': body['ip'],
          'device': body['device'],
          'resource': body['resource']
        },
        permissions: [
          Permission.read(Role.user(body['user'])),
          Permission.read(Role.label('admin')),
        ]);

    context.log('Function execution completed');
    return context.res.json({
      'collections': buckets,
      'total': response.total,
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not list collections',
      'error': e.message,
    });
  }
}
