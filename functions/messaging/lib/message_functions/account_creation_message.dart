import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/constants/constants.dart';

Future<dynamic> accountCreation(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client()
      .setEndpoint(projectEndpoint)
      .setProject(projectID)
      .setKey(api)
      .setSelfSigned(status: true);

  context.log("Setting up Account Creation Messaging...");
  final messaging = Messaging(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);
  final data = body["data"];

  context.log(body.toString());

  try {
    final userID = data["userId"];
    final userName = data["name"];
    final userRole = data["role"];

    context.log("Creating admin email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Creation Notice",
      content: kNewUserAccountAdmin(adminName, userID, userRole),
      html: true,
      users: [adminId],
    ).then((value) {
      context.log("Admin email status: ${value.status}");
    });

    context.log("Creating user email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Creation Notice",
      content: kNewUserAccountClient(userName, adminEmail),
      html: true,
      users: [userID],
    );

    context.log("Emails have been sent!...");
  } catch (e) {
    throw Exception(e);
  }
}
