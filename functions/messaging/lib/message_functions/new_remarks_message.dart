import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/constants/constants.dart';

Future<dynamic> newRemarks(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client()
      .setEndpoint(projectEndpoint)
      .setProject(projectID)
      .setKey(api)
      .setSelfSigned(status: true);

  context.log("Setting up Messaging...");
  final messaging = Messaging(client);

  context.log("Setting up Database...");
  final database = Databases(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    final nurseID = body["nurseId"];
    final patientID = body["patientId"];

    context.log("Fetching nurse...");
    final nurse = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: nurseID,
    );

    context.log("Fetching patient...");
    final patient = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: patientID,
    );

    context.log("Creating user email and sending email...");
    messaging.createEmail(
      messageId: ID.unique(),
      subject: "New Remark Added",
      content: kNewRemarks(nurse.data['name'], patient.data['code']),
      html: true,
      users: [nurseID],
    );

    return context.res.json({
      "data": "Email has been Sent Successfully.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
