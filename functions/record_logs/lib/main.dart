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

  final futures = users.users.map((user) async {
    context.log("Fetching users history logs...");
    final logs = await auth.listLogs(userId: user.$id);

    context.log("Converting users history logs...");
    final logsToMap = logs.logs
        .map((log) => {
              "event": log.event,
              "userId": log.userId,
              "userEmail": log.userEmail,
              "userName": log.userName,
              "mode": log.mode,
              "ip": log.ip,
              "time": log.time,
              "osCode": log.osCode,
              "osName": log.osName,
              "osVersion": log.osVersion,
              "clientType": log.clientType,
              "clientCode": log.clientCode,
              "clientName": log.clientName,
              "clientVersion": log.clientVersion,
              "clientEngine": log.clientEngine,
              "clientEngineVersion": log.clientEngineVersion,
              "deviceName": log.deviceName,
              "deviceBrand": log.deviceBrand,
              "deviceModel": log.deviceModel,
              "countryCode": log.countryCode,
              "countryName": log.countryName,
            })
        .toList();

    return {
      "name": user.name,
      "email": user.email,
      "user_ID": user.$id,
      "role": user.labels,
      "last_activity": logsToMap
      // "status": user.status,
    };
  }).toList();

  context.log("Waiting for futures to complete...");
  final response = await Future.wait(futures);

  context.log("Function completed...");
  return context.res.json({"data": response});
}
