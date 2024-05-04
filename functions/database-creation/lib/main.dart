import 'dart:async';
import 'dart:convert';

import 'package:database_creation/functions/attribute_creation.dart';
import 'package:database_creation/functions/functions.dart';

Future<dynamic> main(final context) async {
  try {
    context.log("Decoding body...");
    final body = json.decode(context.req.bodyRaw);
    final type = body['function_type'] as String;

    if (type == "database_creation") {
      databaseCreation(context);
    } else if (type == "collection_creation") {
      collectionCreation(context);
    } else if (type == "attribute_creation") {
      attributeCreation(context);
    }

    return context.res.json({
      'data': 'function database-creation run successfully!',
    });
  } catch (e) {
    return context.res.json({
      "error": e.toString(),
    });
  }
}
