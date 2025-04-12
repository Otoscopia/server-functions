import 'dart:async';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

// This Appwrite function will be executed every time your function is triggered
Future<dynamic> main(final context) async {
  // You can use the Appwrite SDK to interact with other services
  // For this example, we're using the Users service
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');
  final database = Databases(client);

  final oldDB = "65cc1cdadb3c9b2ded7a";
  final newDB = "6635e2ea0018d0f415e9";

  final oldData = await database.listDocuments(
      databaseId: oldDB,
      collectionId: "65cc1f4eab9aca07bca7",
      queries: [Query.limit(1000)]);

  context.log('mapping old school data');
  for (final school in oldData.documents) {
    context.log('creating users new db');

    await database.createDocument(
        databaseId: newDB,
        collectionId: '67fa3eb2001dc79e4260',
        documentId: school.data['\$id'],
        data: {
          'name': school.data['name'],
          'abbr': school.data['abbr'],
          'code': school.data['code'],
          'address': school.data['address'],
          'is_active': school.data['isActive'],
        });
  }
}
