import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/main.dart';

Future<dynamic> accountDeletion(context) async {
  context.log("Setting up Appwrite client...");
  final client =
      Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

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
      content: kAdminContent(
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
      content: kUserContent(user.data['name']),
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

String kAdminContent(
  String adminName,
  String userName,
  String userId,
  String userEmail,
) =>
    """
<html>
  <p>Dear admin <b>$adminName<b>,</p>

  <p>User <b>$userName</b> has requested to delete their account with the id of $userId, Please verify if their account can be delete and notify the user with their email $userEmail.</p>
</html>
""";

String kUserContent(
  String userName,
) =>
    """
<html>
  <p>Dear <b>$userName<b>,</p>

  <p>You have requested to delete your account, Please wait for the admin response before to delete your account.</p>

  <p>Sincerely,</p>

  <p>Otoscopia Team</p>

  <p>
    <i>
      <b>Disclaimer:</b> This communication is intended solely for the use of the addressee. It may contain confidential or legally privileged information. If you are not the intended recipient, any disclosure, copying, distribution or taking any action in reliance on this communication is strictly prohibited and may be unlawful. If you received this communication in error, please notify the sender immediately and delete this communication from your system. Otoscopia is neither liable for the proper and complete transmission of this communication nor for any delay in its receipt.
    </i>
  </p>
</html>
""";
