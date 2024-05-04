import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:database_creation/constants/appwrite.dart';

Future<dynamic> attributeString(final context) async {
  try {
    context.log("Setting up Appwrite client...");
    final client = Client()
        .setEndpoint(projectEndpoint)
        .setProject(projectID)
        .setKey(api)
        .setSelfSigned(status: true);

    context.log("Setting up Database...");
    final database = Databases(client);

    context.log("Decoding context data...");
    final body = json.decode(context.req.bodyRaw);
    final response = body['data'];

    context.log("Extracting context data...");
    final databaseId = response['db'] as String;
    final collectionId = response['collectionId'] as String;
    final key = response['key'] as String;
    final size = int.parse(response['size'] as String);
    final xrequired = response['required'] as bool;
    final xdefault = response['default'] as String?;
    final encrypt = response['encrypt'] as bool?;
    final array = response['array'] as bool?;

    context.log("Creating Collection...");
    await database.createStringAttribute(
      databaseId: databaseId,
      collectionId: collectionId,
      key: key,
      size: size,
      xrequired: xrequired,
      encrypt: encrypt,
      array: array,
      xdefault: xdefault,
    );

    return context.res.json({
      "data": "Function attribute string creation succeeded.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
