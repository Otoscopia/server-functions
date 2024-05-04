import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/constants/constants.dart';

Future<dynamic> accountValidation(context) async {
  context.log("Setting up Appwrite client...");
  final client =
      Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

  context.log("Setting up Messaging...");
  final messaging = Messaging(client);

  context.log("Setting up Database...");
  final database = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    final userID = body["userId"];
    final userName = body["name"];

    context.log("Fetching user...");
    await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: userID,
    );

    context.log("Creating user email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Validation Notice",
      content: kUserVerified(userName),
      html: true,
      users: [userID],
    );

    return context.res.json({
      "data": "Email has been Sent Successfully.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
