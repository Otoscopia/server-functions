import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:injector/help_function.dart';

late Functions functions;
Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Initializing Appwrite Services...");
  functions = Functions(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    context.log('Fetching Functions...');
    final executions = await functions.list();

    context.log('Filtering collections by IDs...');
    final collectionsId = filterFunction('fetch-collection-ids', executions);
    final bucketsId = filterFunction('fetch-bucket-ids', executions);

    context.log('Executing functions...');
    final collections = await executeFunction(collectionsId, body);
    final buckets = await executeFunction(bucketsId, body);

    return context.res.json({
      'buckets': json.decode(collections.responseBody),
      'collections': json.decode(buckets.responseBody),
    });
  } catch (e) {
    return context.res.json({
      'message': 'Could not execute functions',
      'error': e.toString(),
    }, status: 500);
  }
}
