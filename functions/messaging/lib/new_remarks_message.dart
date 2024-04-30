import 'dart:async';
import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:messaging_function/main.dart';

Future<dynamic> newRemarks(context) async {
  context.log("Setting up Appwrite client...");
  final client = Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

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
      content: kUserContent(nurse.data['name'], patient.data['code']),
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

String kUserContent(
  String nurseName,
  String patientCode,
) =>
    """
<html>
  <p>Dear Nurse <b>$nurseName</b>,</p>

<p>Your patient with the following code: <i>$patientCode</i> and its medical record has been <b>updated</b>. Please log in to your Otoscopia account to view the patient's details along with the updated medical record. Please take necessary action if required and update the patients guardian about the status of the patient.</p>

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
