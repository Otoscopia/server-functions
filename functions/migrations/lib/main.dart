import 'dart:async';

import 'package:dart_appwrite/dart_appwrite.dart';

// This Appwrite function will be executed every time your function is triggered
Future<dynamic> main(final context) async {
  // You can use the Appwrite SDK to interact with other services
  // For this example, we're using the Users service
  final oldClient = Client()
      .setEndpoint('http://165.232.160.201/v1')
      .setProject('65a2440134e8348967fa')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');
  final oldDatabase = Databases(oldClient);

  final oldDB = "65cc1cdadb3c9b2ded7a";

  final oldData = await oldDatabase.listDocuments(
      databaseId: oldDB,
      collectionId: "65cc20961d680cef0cba",
      queries: [Query.limit(1000)]);

  final newClient = Client()
      .setEndpoint('https://cloud.otoscopia.ph/v1')
      .setProject('67ecc3d2001aa5bc3e9b')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');
  final newDatabase = Databases(newClient);

  final newDB = "6635e2ea0018d0f415e9";

  context.log('mapping old school data');
  for (final school in oldData.documents) {
    context.log(
        'creating users new db, ${school.data['\$id']}, ${school.data['school']}');

    await newDatabase.updateDocument(
        databaseId: newDB,
        collectionId: '67ee3a8b001086ef439a',
        documentId: school.data['\$id'],
        data: {'school': school.data['school']['\$id']});
  }
}
