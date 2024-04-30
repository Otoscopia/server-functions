import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/main.dart';

Future<dynamic> accountValidation(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

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
      content: kUserContent(userName),
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

String kUserContent(
  String userName,
) =>
    """
<html>
  <p>Dear <b>$userName<b>,</p>

  <p>Your Otoscopia User Profile has been verified!</p>

  <p>We are looking forward to working with you. You may access your account via the Web, Desktop or the Mobile Application.</p>

  <p>Sincerely,</p>

  <p>Otoscopia Team</p>

  <p>
    <i>
      <b>Disclaimer:</b> This communication is intended solely for the use of the addressee. It may contain confidential or legally privileged information. If you are not the intended recipient, any disclosure, copying, distribution or taking any action in reliance on this communication is strictly prohibited and may be unlawful. If you received this communication in error, please notify the sender immediately and delete this communication from your system. Otoscopia is neither liable for the proper and complete transmission of this communication nor for any delay in its receipt.
    </i>
  </p>
</html>
""";
