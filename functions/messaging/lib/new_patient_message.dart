import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/main.dart';

Future<dynamic> newPatient(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

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
      content: kUserContent(doctor.data['name'], patient.data['code']),
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

String kUserContent(
  String doctorName,
  String patientCode,
) =>
    """
<html>
  <p>Dear Doctor <b>$doctorName</b>,</p>

<p>A new patient has been <b>added</b> to your list with the following code: <i>$patientCode</i>. Please log in to your Otoscopia account to view the patient's details and to schedule an appointment with the patient if necessary.</p>

<p>Thank you and we look forward to the successful treatment of the patient.</p>

  <p>Sincerely,</p>

  <p>Otoscopia Team</p>

  <p>
    <i>
      <b>Disclaimer:</b> This communication is intended solely for the use of the addressee. It may contain confidential or legally privileged information. If you are not the intended recipient, any disclosure, copying, distribution or taking any action in reliance on this communication is strictly prohibited and may be unlawful. If you received this communication in error, please notify the sender immediately and delete this communication from your system. Otoscopia is neither liable for the proper and complete transmission of this communication nor for any delay in its receipt.
    </i>
  </p>
</html>
""";
