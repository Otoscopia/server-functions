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
      return context.res.json({'message': 'No users found', 'users': []});
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
          'email': response.data['email'],
          'verification': response.data['is_verified'],
          'is_phone_verified': response.data['is_phone_verified'],
          'is_email_verified': response.data['is_email_verified'],
          'status': response.data['activity_status']['status']['name'],
          'mfa': response.data['mfa_enabled'],
          'last_password_updated': response.data['last_password_updated'],
          'password_expiration': response.data['account_status']
              ['password_expiration'],
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
      'message': 'Authentication Users fetched successfully',
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
