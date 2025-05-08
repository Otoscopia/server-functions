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
  final account = Account(client);
  final databases = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);
  final id = body['user'];

  final String database = Platform.environment["DATABASE"] ?? "";
  final String userCollection = Platform.environment["USER_COLLECTION"] ?? "";
  final String logsCollection = Platform.environment["LOGS_COLLECTION"] ?? "";

  try {
    context.log("Creating reset password mail...");
    final user = await databases.getDocument(
        databaseId: database, collectionId: userCollection, documentId: id);

    await account.createRecovery(
        email: user.data['email'],
        url: 'https://app.otoscopia.ph/reset-password');
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
      'title': 'Password reset',
      'message': 'Reset password to ${user.data['email']} has been sent',
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
