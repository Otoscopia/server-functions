import 'dart:async';
// import 'dart:convert';
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
  final teamsCollectionId = Platform.environment['TEAMS_COLLECTION'] ?? '';
  final rolesCollectionId = Platform.environment['ROLES_COLLECTION'] ?? '';

  context.log(
      "Decoding body..., $databaseId, $teamsCollectionId, $rolesCollectionId");
  // final body = json.decode(context.req.bodyRaw);

  try {
    final teamsList = await databases.listDocuments(
        databaseId: databaseId, collectionId: teamsCollectionId);
    final rolesList = await databases.listDocuments(
        databaseId: databaseId, collectionId: rolesCollectionId);

    final teams = teamsList.documents.map((t) => t.data).toList();
    final roles = rolesList.documents.map((r) => r.data).toList();

    return context.res.json({
      'teams': teams,
      'teams_total': teamsList.total,
      'roles': roles,
      'roles_total': rolesList.total
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not fetch roles and teams permissions',
      'error': e.message,
    });
  }
}
