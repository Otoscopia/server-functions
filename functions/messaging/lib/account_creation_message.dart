import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/main.dart';

Future<dynamic> accountCreation(context) async {
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
    final userRole = body["role"];

    context.log("Fetching admin data...");
    final admin = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: adminId,
    );

    context.log("Creating admin email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Creation Notice",
      content: kAdminContent(admin.data['name'], userID, userRole),
      html: true,
      users: [admin.$id],
    ).then((value) {
      context.log("Admin email status: ${value.status}");
    });

    context.log("Creating user email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "Account Creation Notice",
      content: kUserContent(userName, admin.data['email']),
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

String kAdminContent(
  String adminName,
  String userId,
  String userRole,
) =>
    """
<html>
  <p>Dear admin <b>$adminName<b>,</p>

  <p>A new account has been created with the id of <b>$userId</b> and role of <b>$userRole</b>. Please verify the account status so that they can continue with the application.</p>
</html>
""";

String kUserContent(
  String userName,
  String adminEmail,
) =>
    """
<html>
  <p>Dear <b>$userName<b>,</p>

  <p>Thank you for creating your User Profile! You are halfway in opening your Otoscopia account with Otoscopia Team.</p>

  <p>We are excited to have you on board and we are looking forward to working with you. We will be in touch with you soon to discuss the next steps. In the meantime, if you have any questions, please feel free to reach out to us at $adminEmail.</p>

  Thank you and we look forward to welcoming you to the Otoscopia family.</p>

  <p>Sincerely,</p>

  <p>Otoscopia Team</p>

  <p>
    <i>
      <b>Disclaimer:</b> This communication is intended solely for the use of the addressee. It may contain confidential or legally privileged information. If you are not the intended recipient, any disclosure, copying, distribution or taking any action in reliance on this communication is strictly prohibited and may be unlawful. If you received this communication in error, please notify the sender immediately and delete this communication from your system. Otoscopia is neither liable for the proper and complete transmission of this communication nor for any delay in its receipt.
    </i>
  </p>
</html>
""";
