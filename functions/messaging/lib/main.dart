import 'dart:async';
import 'dart:convert';

import 'package:messaging_function/message_functions/index.dart';

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

    return context.res.json({
      "data": "Function messaging created and sent emails successfully!",
    });
  } catch (e) {
    return context.res.json({
      "error": e.toString(),
    });
  }
}
