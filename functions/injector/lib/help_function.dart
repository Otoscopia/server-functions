import 'package:dart_appwrite/enums.dart';
import 'package:dart_appwrite/models.dart';
import 'package:injector/main.dart';

filterFunction(String name, FunctionList functionList) {
  final list = functionList.functions.where((e) => e.name == name).first;
  return list.$id;
}

Future<Execution> executeFunction(String id, String body) async {
  return await functions.createExecution(
    functionId: id,
    body: body,
    method: ExecutionMethod.gET,
  );
}
