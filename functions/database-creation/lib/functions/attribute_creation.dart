import 'dart:async';
import 'dart:convert';

import 'package:database_creation/functions/attribute_functions/attribute_string.dart';

Future<dynamic> attributeCreation(final context) async {
  try {
    context.log("Decoding body attributes...");
    final body = json.decode(context.req.bodyRaw);
    final response = body['data']['attributes'];

    if (response == 'string') {
      context.log("Attribute type of String, Creating String Attribute...");
      attributeString(context);
    }
  } catch (e) {
    throw Exception(e);
  }
}
