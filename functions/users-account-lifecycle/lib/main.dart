import 'dart:async';
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
  final db = Databases(client);

  final String database = Platform.environment["DATABASE"] ?? "";
  final String userCollection = Platform.environment["USER_COLLECTION"] ?? "";

  try {
    context.log("Fetching Users...");
    final response = await users.list();

    if (response.total == 0) {
      return context.res.json({
        'message': 'No users found',
        'users': [],
      });
    }

    context.log("Fetching user details...");
    List<Map<String, dynamic>> userList = [];

    context.log("Looping users...");
    for (var user in response.users) {
      try {
        context.log("Fetching user ${user.$id}...");
        final response = await db.getDocument(
          databaseId: database,
          collectionId: userCollection,
          documentId: user.$id,
        );

        userList.add({
          'id': user.$id,
          'name': response.data['readable_name'],
          'role': response.data['role']['key'],
          'activity_status': response.data['activity_status']['status']['name'],
          'account_status': response.data['account_status']['status']['name'],
          'created_at': user.$createdAt,
        });
      } on AppwriteException catch (e) {
        if (e.type == 'document_not_found') {
          context.log("Skipping user without document: ${user.$id}");
        } else {
          context.log("Error fetching: $e");
        }
      }
    }

    return context.res.json({
      'message': 'Users fetched successfully',
      'users': userList,
      'total': response.total,
    });
  } on AppwriteException catch (e) {
    context.error('Could not list users: $e');
    return context.res.json({
      'message': 'Could not list users',
      'error': e.message,
    });
  }
}
