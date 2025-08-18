import 'dart:convert';

import 'package:frontend/core/constants/constanats.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/models/task_model.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class TaskRemoteRepository {
  final TaskLocalRepository _taskLocalRepository = TaskLocalRepository();
  Future<TaskModel> createTask({
    required String title,
    required String description,
    required String userId,
    required DateTime dueDate,
    required String token,
    required String hexColor,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${constants.apiBaseUrl}/task/"),
        headers: {'Content-Type': 'application/json', "x-auth-token": token},
        body: jsonEncode({
          'title': title,
          'description': description,
          'dueDate': dueDate.toIso8601String(),
          'hexColor': hexColor,
        }),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create task: ${response.reasonPhrase}');
      }
      return TaskModel.fromMap(jsonDecode(response.body));
    } catch (e) {
      try {
        final taskModel = TaskModel(
          id: const Uuid().v4(),
          userId: userId,
          title: title,
          description: description,
          dueDate: dueDate,
          hexColor: hexColor,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completed: false,
          isSynced: 0,
        );
        await _taskLocalRepository.insertTask(taskModel);
        return taskModel;
      } catch (e) {
        print('Error creating task: $e');
        throw Exception('Failed to create task');
      }
      // Handle exceptions, possibly log them or rethrow
    }
    // Implementation for creating a task
  }

  Future<List<TaskModel>> getTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${constants.apiBaseUrl}/task/"),
        headers: {'Content-Type': 'application/json', "x-auth-token": token},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch tasks: ${response.reasonPhrase}');
      }
      final listOfTask = jsonDecode(response.body);
      final List<TaskModel> taskList = [];
      for (var elem in listOfTask) {
        taskList.add(TaskModel.fromMap(elem));
      }
      await _taskLocalRepository.insertTasks(taskList);
      return taskList;
    } catch (e) {
      // Fetch tasks from local repository if remote fetch fails
      final localTasks = await _taskLocalRepository.getTasks();
      if (localTasks.isNotEmpty) {
        return localTasks
            .where((task) => task != null)
            .cast<TaskModel>()
            .toList();
      }
      // Handle exceptions, possibly log them or rethrow
      print('Error fetching tasks: $e');
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<bool> syncTaks({
    required String token,
    required List<TaskModel> tasks,
  }) async {
    try {
      final taskListInMap = tasks.map((task) {
        final map = task.toMap();
        // Convert any Sets to List
        map.forEach((key, value) {
          if (value is Set) {
            map[key] = value.toList();
          }
        });
        return map;
      }).toList();

      final response = await http.post(
        Uri.parse("${constants.apiBaseUrl}/task/sync"),
        headers: {'Content-Type': 'application/json', "x-auth-token": token},
        body: jsonEncode(taskListInMap),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create task: ${response.reasonPhrase}');
      }
      return true;
    } catch (e) {
      rethrow;
      // Implementation for creating a task
    }
  }
}
