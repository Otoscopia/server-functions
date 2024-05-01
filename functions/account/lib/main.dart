import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/enums.dart';

final String projectEndpoint = Platform.environment["APPWRITE_ENDPOINT"]!;
final String projectID = Platform.environment["APPWRITE_PROJECT"]!;
final String api = Platform.environment["API"]!;

final String databaseID = Platform.environment["DATABASE"]!;
final String usersCollection = Platform.environment["USER_COLLECTION"]!;
final String schoolCollection = Platform.environment["SCHOOL_COLLECTION"]!;
final String assignmentCollection = Platform.environment["ASSIGNMENT_COLLECTION"]!;

final String adminId = Platform.environment["ADMIN_ID"]!;

final String messageID = Platform.environment["MESSAGE_FUNCTION"]!;

Future<dynamic> main(final context) async {
  context.log("Setting up Appwrite client...");
  final client = Client().setEndpoint(projectEndpoint).setProject(projectID).setKey(api);

  context.log("Setting up Database...");
  final database = Databases(client);

  context.log("Setting up users...");
  final user = Users(client);

  context.log("Setting up function...");
  final function = Functions(client);

  context.log("Decoding body...");
  final body = json.decode(context.req.bodyRaw);

  try {
    final userID = body["userId"];
    final userName = body["name"];
    final userEmail = body["email"];
    final userPhone = body["phone"];
    final userRole = body["role"];

    context.log("Creating user data...");
    await database.createDocument(
      databaseId: databaseID,
      collectionId: usersCollection,
      documentId: userID,
      data: {
        "name": userName,
        "email": userEmail,
        "phone": userPhone,
        "workAddress": body["workAddress"],
        "role": userRole,
      },
      permissions: [
        Permission.update(Role.user(userID)),
        Permission.delete(Role.label("admin"))
      ],
    );

    context.log("Updating user account...");
    await user.updatePhone(userId: userID, number: userPhone);
    await user.updateLabels(userId: userID, labels: [userRole]);

    if (userRole == "nurse") {
      context.log("Creating assignment...");
      final schools = List<dynamic>.from(body["school"]);

      context.log("Updating school data...");
      for (final school in schools) {
        await database.createDocument(
          databaseId: databaseID,
          collectionId: assignmentCollection,
          documentId: ID.unique(),
          data: {
            "isActive": true,
            "nurse": userID,
            "school": school,
          },
        );

        await database.updateDocument(
          databaseId: databaseID,
          collectionId: schoolCollection,
          documentId: school,
          data: {
            "isAssigned": true,
          },
        );
      }
    }

    context.log("Updating user...");
    await user.updatePhone(userId: userID, number: userPhone);
    await user.updateLabels(userId: userID, labels: [userRole]);

    if (userRole == "nurse") {
      context.log("Creating assignment...");
      final schools = List<dynamic>.from(body["school"]);

      context.log("Updating school data...");
      for (final school in schools) {
        await database.createDocument(
          databaseId: databaseID,
          collectionId: assignmentCollection,
          documentId: ID.unique(),
          data: {
            "isActive": true,
            "nurse": userID,
            "school": school,
          },
        );

        await database.updateDocument(
          databaseId: databaseID,
          collectionId: schoolCollection,
          documentId: school,
          data: {
            "isAssigned": true,
          },
        );
      }
    }

    await function.createExecution(
      functionId: messageID,
      body: json.encode({
        "message_type": "account_creation",
        "data": {
          "userId": userID,
          "name": userName,
          "role": userRole,
        },
      }),
      path: '/',
      method: ExecutionMethod.pOST,
    );

    return context.res.json({
      "data": "Account creation successfull.",
    });
  } catch (e) {
    throw Exception(e);
  }
}
