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
  final db = Databases(client);

  final String database = Platform.environment["DATABASE"] ?? "";
  final String userCollection = Platform.environment["USER_COLLECTION"] ?? "";
  final String logsCollection = Platform.environment["LOGS_COLLECTION"] ?? "";
  final String accountStatusCollection =
      Platform.environment["ACCOUNT_CONFIG_COLLECTION"] ?? "";
  final String accountStatusDocument =
      Platform.environment["ACCOUNT_CONFIG_DOCUMENT"] ?? "";

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    context.log("Fetching Users...");
    final response = await users.list(queries: [
      Query.limit(body['limit']),
      Query.offset(body['offset']),
    ]);

    final accounntConfigurations = await db.getDocument(
        databaseId: database,
        collectionId: accountStatusCollection,
        documentId: accountStatusDocument);

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
          'email': response.data['email'],
          'verification': response.data['is_verified'],
          'is_phone_verified': response.data['is_phone_verified'],
          'is_email_verified': response.data['is_email_verified'],
          'mfa': response.data['mfa_enabled'],
          'last_password_updated': response.data['last_password_updated'],
          'password_expiration':
              accounntConfigurations.data['password_expiration']['value'],
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

    context.log('Logging user data');
    await db.createDocument(
      databaseId: database,
      collectionId: logsCollection,
      documentId: ID.unique(),
      data: {
        'user': body['user'],
        'role': body['role'],
        'event': '6803b3b2002503ee14f4',
        'location': body['location'],
        'ip': body['ip'],
        'device': body['device'],
      },
      permissions: [
        Permission.read(Role.user(body['user'])),
        Permission.read(Role.label('admin')),
      ],
    );

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
