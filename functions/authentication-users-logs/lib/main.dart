// import 'dart:async';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

final String projectEndpoint = Platform.environment["APPWRITE_ENDPOINT"]!;
final String projectID = Platform.environment["APPWRITE_PROJECT"]!;
final String api = Platform.environment["API"]!;

final String usersCollection = Platform.environment["USER_COLLECTION"]!;

Future<dynamic> main(final context) async {
  context.log("Setting up Appwrite client...");
  final client = Client()
      .setEndpoint(projectEndpoint)
      .setProject(projectID)
      .setKey(api)
      .setSelfSigned(status: true);

  final auth = Users(client);
  final users = await auth.list();
  return context.res.json({
    "data": users.users
        .map((user) => {
              "name": user.name,
              "email": user.email,
              "email-verification": user.emailVerification,
              "phone-verification": user.phoneVerification,
              "status": user.status,
              "mfa": user.mfa,
              "password-last-updated": user.passwordUpdate,
              // "password-expiration" : user.passwordExpiration,
            })
        .toList(),
  });
}
