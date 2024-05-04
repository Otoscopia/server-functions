import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/constants/constants.dart';

Future<dynamic> accountDeletion(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client()
      .setEndpoint(projectEndpoint)
      .setProject(projectID)
      .setKey(api)
      .setSelfSigned(status: true);

  context.log("Setting up Messaging...");
  final messaging = Messaging(client);
  final database = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  final id = body["userId"];

  try {
    context.log("Fetching user data...");
    final user = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: id,
    );

    context.log("Fetching admin data...");
    final admin = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: adminId,
    );

    context.log("Creating admin email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Deletion Verification",
      content: kDeleteAccountAdmin(
        admin.data['name'],
        user.data['name'],
        user.data['$id'],
        user.data['email'],
      ),
      html: true,
      users: [admin.$id],
    ).then((value) {
      context.log("Admin email status: ${value.status}");
    });

    context.log("Creating user email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Deletion Notice",
      content: kDeleteAccountClient(user.data['name']),
      html: true,
      users: [user.$id],
    ).then((value) {
      context.log("User email status: ${value.status}");
    });

    return context.res.json({
      "data": "Email has been Sent Successfully.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
