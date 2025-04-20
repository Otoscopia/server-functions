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
  final logsId = Platform.environment['LOGS_COLLECTION'] ?? '';
  final eventsId = Platform.environment['EVENTS_COLLECTION'] ?? '';

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    context.log('Fetching Events Collections...');
    final response = await databases.listDocuments(
        databaseId: databaseId, collectionId: eventsId);

    context.log('Converting to readable documents...');
    final events = response.documents.map((e) {
      return {
        'id': e.$id,
        'method': e.data['method'],
        'resource': e.data['resource'],
        'activity': e.data['activity']
      };
    }).toList();

    context.log('Logging user data');
    await databases.createDocument(
        databaseId: databaseId,
        collectionId: logsId,
        documentId: ID.unique(),
        data: {
          'user': body['user'],
          'role': body['role'],
          'event': '6803c1f600272f1719e6',
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
      'events': events,
      'total': response.total,
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not list collections',
      'error': e.message,
    });
  }
}
