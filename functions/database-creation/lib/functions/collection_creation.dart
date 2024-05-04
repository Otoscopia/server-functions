import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:database_creation/constants/appwrite.dart';

Future<dynamic> collectionCreation(final context) async {
  context.log("Setting up Appwrite client...");
  final client = Client()
      .setEndpoint(projectEndpoint)
      .setProject(projectID)
      .setKey(api)
      .setSelfSigned(status: true);

  final database = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);
  final response = body['data'];

  final String databaseId = response['db'];
  final String collectionId = response['collectionId'] ?? ID.unique();
  final String collectionName = response['collectionName'];
  final bool collectionDocumentSecurity = response['documentSecurity'];
  final bool collectionEnabled = response['enabled'];
  final collectionPermissions = List<String>.from(response['permissions']);

  context.log("Creating Collection...");
  await database.createCollection(
    databaseId: databaseId,
    collectionId: collectionId,
    name: collectionName,
    documentSecurity: collectionDocumentSecurity,
    enabled: collectionEnabled,
    permissions: collectionPermissions,
  );

  return context.res.json({
    "data": "Function collection creation succeeded.",
  });
}
