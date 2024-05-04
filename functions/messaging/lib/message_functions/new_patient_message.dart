import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/constants/constants.dart';

Future<dynamic> newPatient(context) async {
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
    final doctorID = body["doctorId"];
    final patientID = body["patientId"];

    context.log("Fetching doctor...");
    final doctor = await database.getDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: doctorID,
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
      subject: "New Patient Added",
      content: kNewPatient(doctor.data['name'], patient.data['code']),
      html: true,
      users: [doctorID],
    );

    return context.res.json({
      "data": "Email has been Sent Successfully.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
