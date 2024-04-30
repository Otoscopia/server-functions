import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:messaging_function/account_creation_message.dart';
import 'package:messaging_function/account_validation_message.dart';
import 'package:messaging_function/delete_account_message.dart';
import 'package:messaging_function/new_patient_message.dart';
import 'package:messaging_function/new_remarks_message.dart';
import 'package:messaging_function/password_reset_message.dart';

// Appwrite Client environment variables
final String projectEndpoint = Platform.environment["APPWRITE_ENDPOINT"]!;
final String projectID = Platform.environment["APPWRITE_PROJECT"]!;
final String api = Platform.environment["API"]!;

final String databaseID = Platform.environment["DATABASE"]!;
final String usersCollection = Platform.environment["USER_COLLECTION"]!;

final String adminId = Platform.environment["ADMIN_ID"]!;

Future<dynamic> main(final context) async {
  context.log("Decoding body to get message type...");
  final body = json.decode(context.req.bodyRaw);
  final response = body['message_type'] as String;

  try {
    if (response == "request_account_deletion") {
      accountDeletion(context);
    } else if (response == "account_creation") {
      accountCreation(context);
    } else if (response == "account_validation") {
      accountValidation(context);
    } else if (response == "new_remark") {
      newRemarks(context);
    } else if (response == "new_patient") {
      newPatient(context);
    } else if (response == "password_reset") {
      passwordReset(context);
    // } else if (response == "new_screening") {
    // } else if (response == "patient_refer") {
    // } else if (response == "mfa_enabled") {
    // } else if (response == "mfa_disabled") {
    } else {
      return context.res.json({
        "error": "Invalid message type",
      });
    }
  } catch (e) {
    return context.res.json({
      "error": e.toString(),
    });
  }
}
