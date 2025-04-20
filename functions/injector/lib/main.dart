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

  final body = context.req.bodyRaw;

  try {
    context.log('Fetching Functions...');
    final executions = await functions.list();

    context.log('Filtering collections by IDs...');
    final collectionsId = filterFunction('fetch-collection-ids', executions);
    final bucketsId = filterFunction('fetch-bucket-ids', executions);
    final eventsId = filterFunction('fetch-event-ids', executions);

    context.log('Executing functions...');
    final collections = await executeFunction(collectionsId, body);
    final buckets = await executeFunction(bucketsId, body);
    final events = await executeFunction(eventsId, body);

    context.log('Converting functions to readable ids');
    context.log('Converting response to readable collections...');
    final functionIds = executions.functions
        .map((function) => {'id': function.$id, 'name': function.name})
        .toList();

    return context.res.json({
      'databases': json.decode(collections.responseBody),
      'buckets': json.decode(buckets.responseBody),
      'events': json.decode(events.responseBody),
      'functions': {
        'functions': functionIds,
        'total': executions.total,
      }
    });
  } on AppwriteException catch (e) {
    return context.res.json({
      'message': 'Could not execute functions',
      'error': e.message,
    });
  }
}
