import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

Future<dynamic> main(final context) async {
  context.log('Setting up Appwrite Client...');
  final client = Client()
      .setEndpoint(Platform.environment['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '')
      .setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'] ?? '')
      .setKey(context.req.headers['x-appwrite-key'] ?? '');

  context.log("Setting up Appwrite Services...");
  final databases = Databases(client);
  final storages = Storage(client);
  final users = Users(client);

  context.log("Fetching environment variables...");
  final databaseId = Platform.environment['DATABASE'] ?? '';

  final userCollectionId = Platform.environment['USER_COLLECTION'] ?? '';
  final rolesCollectionId = Platform.environment['ROLES_COLLECTION'] ?? '';
  // final filesCollectionId = Platform.environment['files'] ?? '';
  final teamsCollectionId = Platform.environment['TEAMS_COLLECTION'] ?? '';
  final permissionsCollectionId =
      Platform.environment['PERMISSIONS_COLLECTION'] ?? '';
  final logsCollectionId = Platform.environment['LOGS_COLLECTION'] ?? '';
  final schoolsCollectionId = Platform.environment['SCHOOLS_COLLECTION'] ?? '';
  final patientsCollectionId =
      Platform.environment['PATIENTS_COLLECTION'] ?? '';

  try {
    context.log("Executing queries...");
    final futures = await Future.wait([
      // Count users
      databases.listDocuments(
        databaseId: databaseId,
        collectionId: userCollectionId,
        queries: [Query.limit(1)],
      ),

      // Count roles
      databases.listDocuments(
        databaseId: databaseId,
        collectionId: rolesCollectionId,
        queries: [Query.limit(1)],
      ),

      databases.listDocuments(
        databaseId: databaseId,
        collectionId: teamsCollectionId,
        queries: [Query.limit(1)],
      ),

      // Count permissions
      databases.listDocuments(
        databaseId: databaseId,
        collectionId: permissionsCollectionId,
        queries: [Query.limit(1)],
      ),

      // Get recent logs
      databases.listDocuments(
        databaseId: databaseId,
        collectionId: logsCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(10),
        ],
      ),

      // Get schools
      databases.listDocuments(
        databaseId: databaseId,
        collectionId: schoolsCollectionId,
        queries: [Query.limit(100)],
      ),
    ]);

    context.log("Getting queries total...");
    final usersCount = futures[0].total;
    final rolesCount = futures[1].total;
    final teamsCount = futures[2].total;
    final permissionsCount = futures[3].total;
    final recentLogs = futures[4];
    final schools = futures[5];
    final bucketsCount = await storages.listBuckets();

    int files = 0;
    for (final data in bucketsCount.buckets) {
      final response = await storages.listFiles(bucketId: data.$id);
      files += response.total;
    }

    final filesCount = files;

    final blockedUsers =
        await users.list(queries: [Query.equal('status', false)]);
    final activeUsers =
        await users.list(queries: [Query.equal('status', true)]);

    // Process recent activities
    context.log("Converting recent logs to readable format...");
    final recentActivities = recentLogs.documents.map((log) {
      final data = log.data;
      final eventData = data['event'] as Map<String, dynamic>? ?? {};

      return {
        'id': log.$id,
        'type': eventData['activity'] ?? 'unknown',
        'description':
            '${eventData['method'] ?? ''} ${eventData['resource'] ?? ''} ${eventData['activity'] ?? ''}',
        'user_name':
            (data['user'] as Map<String, dynamic>?)?['readable_name'] ??
                'Unknown User',
        'time': formatTimeAgo(log.$createdAt),
        'details': data,
      };
    }).toList();

    // Get patient counts for each school
    final schoolsWithPatients = await getSchoolsWithPatientCounts(
      databases,
      databaseId,
      schools.documents,
      patientsCollectionId,
    );

    // Create response data
    context.log("Generating response data...");
    final responseData = {
      'users_count': usersCount,
      'roles_count': rolesCount,
      'teams_count': teamsCount,
      'files_count': filesCount,
      'permissions_count': permissionsCount,
      'recent_activities': recentActivities,
      'schools': schools.total,
      'patients_per_school': schoolsWithPatients,
      'timestamp': DateTime.now().toIso8601String(),
      'blocked_users': blockedUsers.total,
      'active_users': activeUsers.total,
    };

    context.log("Data ${json.encode(responseData)}");

    // Return success response
    return context.res.json({'data': responseData});
  } on AppwriteException catch (e) {
    context.log('Error fetching dashboard data: $e');

    return context.res.json({
      'success': false,
      'message': 'Failed to fetch dashboard data',
      'error': e.message,
    });
  }
}

// Helper function to format time ago from a timestamp
String formatTimeAgo(String timestamp) {
  final now = DateTime.now();
  final time = DateTime.parse(timestamp);
  final difference = now.difference(time);

  if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  } else {
    return 'Just now';
  }
}

// Helper function to get patient counts for each school
Future<List<Map<String, dynamic>>> getSchoolsWithPatientCounts(
  Databases databases,
  String databaseId,
  List<Document> schools,
  String patientsCollectionId,
) async {
  final List<Future<Map<String, dynamic>>> futures =
      schools.map((school) async {
    final patients = await databases.listDocuments(
      databaseId: databaseId,
      collectionId: patientsCollectionId,
      queries: [
        Query.equal('school', school.$id),
        Query.limit(1),
      ],
    );

    return {
      'id': school.$id,
      'school': school.data['name'] ?? 'Unknown School',
      'patient_count': patients.total,
    };
  }).toList();

  // Wait for all futures to complete
  final results = await Future.wait(futures);

  // Sort by patient count in descending order
  results.sort((a, b) =>
      (b['patient_count'] as int).compareTo(a['patient_count'] as int));

  return results;
}
