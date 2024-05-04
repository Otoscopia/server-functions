import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:database_creation/constants/appwrite.dart';

Future<dynamic> databaseCreation(final context) async {
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
  final databaseId = response['db'] ?? ID.unique();
  final databaseName = response['db'] as String;
  final databaseEnabled = response['enabled'] as bool;

  context.log("Creating Database...");
  await database.create(
    databaseId: databaseId,
    name: databaseName,
    enabled: databaseEnabled,
  );

  return context.res.json({
    "data": "Function database creation succeeded.",
  });
}
