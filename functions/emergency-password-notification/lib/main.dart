import 'dart:async';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';

// This Appwrite function will be executed every time your function is triggered
Future<dynamic> main(final context) async {
  // You can use the Appwrite SDK to interact with other services
  // For this example, we're using the Users service
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');
  final users = Users(client);
  final messaging = Messaging(client);

  try {
    final response = await users.list();
    final usersId = response.users.map((u) => u.$id).toList();

    await messaging.createEmail(
      messageId: ID.unique(),
      subject: "Otoscopia Emergency Password Reset Notification (Test)",
      content: """
Dear Otoscopia Users,

We are the research team behind the Otoscopia ENT Application. This email is part of a demonstration and test of our emergency notification system.

⚠️ **Please note: This is only a test.**  
There has been no unauthorized access to the system. All sensitive operations are currently disabled for safety during this demo.

As part of this simulation, we kindly ask you to **reset your Otoscopia account password immediately** as if a real emergency had occurred.

Thank you for your attention and cooperation.  
Stay safe,  
_Otoscopia Research & Development Team_
""",
      scheduledAt: DateTime.now().toIso8601String(),
      users: usersId,
    );
    return context.res.json({
      'message': 'Message has been sent to all users.',
    });
  } on AppwriteException catch (e) {
    context.log(
        'Error could not send emergency password notification to all users: $e');

    return context.res.json({
      'success': false,
      'message':
          'Error could not send emergency password notification to all users',
      'error': e.message,
    });
  }
}
