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

  context.log("Setting up Appwrite Users Service...");
  final users = Users(client);
  final databases = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);
  final id = body['user'];

  final String database = Platform.environment["DATABASE"] ?? "";
  final String userCollection = Platform.environment["USER_COLLECTION"] ?? "";
  final String logsCollection = Platform.environment["LOGS_COLLECTION"] ?? "";

  try {
    context.log("Verifying user email address...");
    await users.updateEmailVerification(userId: id, emailVerification: true);

    context.log("Verifying user email address...");
    final user = await databases.getDocument(
        databaseId: database, collectionId: userCollection, documentId: id);

    context.log('Logging user data');
    await databases.createDocument(
      databaseId: database,
      collectionId: logsCollection,
      documentId: ID.unique(),
      data: {
        'user': id,
        'role': body['role'],
        'event': body['event'],
        'location': body['location'],
        'ip': body['ip'],
        'device': body['device'],
      },
      permissions: [
        Permission.read(Role.user(id)),
        Permission.read(Role.label('admin')),
      ],
    );

    return context.res.json({
      'title': 'Email address has been verified',
      'message': '${user.data['readable_name']} email has been verified',
      'severity': 'success',
    });
  } on AppwriteException catch (e) {
    context.error('Could not verify users email address: $e');
    return context.res.json({
      'message': 'Could not verify users email address',
      'error': e.message,
    });
  }
}
