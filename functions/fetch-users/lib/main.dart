import 'dart:async';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Initializing Appwrite Services...");
  final users = Users(client);

  try {
    context.log("Fetching Users...");
    final response = await users.list();

    final data =
        response.users.map((u) => {"name": u.name, "id": u.$id}).toList();

    return context.res.json({
      'users': data,
      'total': response.total,
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not list users',
      'error': e.message,
    });
  }
}
