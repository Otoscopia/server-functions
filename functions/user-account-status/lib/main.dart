// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

late Users users;
late Databases databases;
late String database;
late String userCollection;
late String logsCollection;
late String accountStatusCollection;

final ACTIVATED = '67bf07e60034236b8b77';
final DEACTIVATED = '67bf07ea0022e1fa81ec';

Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Setting up Appwrite Users Service...");
  users = Users(client);
  databases = Databases(client);

  database = Platform.environment["DATABASE"] ?? "";
  userCollection = Platform.environment["USER_COLLECTION"] ?? "";
  logsCollection = Platform.environment["LOGS_COLLECTION"] ?? "";
  accountStatusCollection =
      Platform.environment["ACCOUNT_STATUSES_COLLECTION"] ?? "";

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);
  final userId = body['id'];
  final activateImmediately = body['activateImmediately'] as bool;
  final deactivateImmediately = body['deactivateImmediately'] as bool;

  context.log("Body: ${context.req.bodyRaw}...");
  try {
    context.log("Fetching user data...");
    final user = await databases.getDocument(
        databaseId: database, collectionId: userCollection, documentId: userId);

    if (activateImmediately) {
      context.log("Activating User Data...");
      await updateUserAccount(
        context: context,
        userId: userId,
        status: true,
        documentId: user.data['account_status']['\$id'],
        data: {
          'status': ACTIVATED,
          'activation_date': body['activation_date'],
          'deactivation_date': null,
        },
      );
    } else if (deactivateImmediately) {
      context.log("Deactivating User Data...");
      await updateUserAccount(
        context: context,
        userId: userId,
        status: false,
        documentId: user.data['account_status']['\$id'],
        data: {
          'status': DEACTIVATED,
          'activation_date': null,
          'deactivation_date': body['deactivation_date'],
        },
      );
    } else {
      context.log("Updating User Data...");
      await databases.createDocument(
        databaseId: database,
        collectionId: accountStatusCollection,
        documentId: user.data['account_status']['\$id'],
        data: {
          'activation_date': body['activation_date'],
          'deactivation_date': body['deactivation_date'],
        },
      );
    }

    context.log("Creating logs...");
    await databases.createDocument(
      databaseId: database,
      collectionId: logsCollection,
      documentId: ID.unique(),
      data: {
        'user': body['user'],
        'role': body['role'],
        'event': '680b65c600104ac97ca8',
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
      'message': 'Users account updated successfuly',
    });
  } on AppwriteException catch (e) {
    context.error('Could update user account: $e');
    return context.res.json({
      'message': 'Could update user account',
      'error': e.message,
    });
  }
}

Future<void> updateUserAccount({
  context,
  required String documentId,
  required String userId,
  required bool status,
  required Map<String, dynamic> data,
}) async {
  context.log("Updating User Auth...");
  await users.updateStatus(userId: userId, status: status);

  context.log("Updating User Document with data:");
  context.log("$database:");
  context.log("$accountStatusCollection:");
  context.log("$documentId:");
  context.log("${json.encode(data)}:");
  await databases.updateDocument(
    databaseId: database,
    collectionId: accountStatusCollection,
    documentId: documentId,
    data: data,
  );
}
