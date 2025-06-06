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

  final databaseId = Platform.environment['DATABASE'] ?? '';

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    context.log('Fetching Database Collections...');
    final response = await databases.listCollections(databaseId: databaseId);

    context.log('Converting response to readable collections...');
    final collections = response.collections
        .map((collection) => {'id': collection.$id, 'name': collection.name})
        .toList();

    context.log('Logging user data');
    final logs =
        collections.where((collection) => collection['name'] == 'logs');

    await databases.createDocument(
        databaseId: databaseId,
        collectionId: logs.first['id']!,
        documentId: ID.unique(),
        data: {
          'user': body['user'],
          'role': body['role'],
          'event': '6803b337000a2a24b63b',
          'location': body['location'],
          'ip': body['ip'],
          'device': body['device'],
        },
        permissions: [
          Permission.read(Role.user(body['user'])),
          Permission.read(Role.label('admin')),
        ]);

    context.log('Function execution completed');
    return context.res.json({
      'database': databaseId,
      'collections': collections,
      'total': response.total,
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not list collections',
      'error': e.message,
    });
  }
}
