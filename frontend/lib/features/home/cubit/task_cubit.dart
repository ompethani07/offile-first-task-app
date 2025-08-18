import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/features/home/repository/task_local_repository.dart';
import 'package:frontend/features/home/repository/task_remote_repository.dart';
import 'package:frontend/models/task_model.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  final TaskRemoteRepository _taskRemoteRepository = TaskRemoteRepository();
  final TaskLocalRepository _taskLocalRepository = TaskLocalRepository();
  Future<void> createTask({
    required String title,
    required Color color,
    required String description,
    required DateTime dueDate,
    required String token,
    required String userId,
  }) async {
    try {
      emit(TaskLoading());
      final taskModel = await _taskRemoteRepository.createTask(
        userId: userId,
        title: title,
        description: description,
        dueDate: dueDate,
        token: token,
        hexColor: rgbToHex(color),
      );
      await _taskLocalRepository.insertTask(taskModel);
      emit(AddNewTaskSuccess('Task created successfully', taskModel));
    } catch (e) {
      emit(AddNewTaskError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> getAllTasks({required String token}) async {
    try {
      emit(TaskLoading());
      final tasks = await _taskRemoteRepository.getTasks(token);
      emit(GetTaskSuccess(tasks));
    } catch (e) {
      emit(AddNewTaskError('Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> syncTasks(String token) async {
    final List<TaskModel> unsyncedTask = await _taskLocalRepository
        .getUnSyncedTask();
    if (unsyncedTask.isEmpty) {
      return;
    }
    final isSynced = await _taskRemoteRepository.syncTaks(
      token: token,
      tasks: unsyncedTask,
    );
    if (isSynced) {
      print("synced done !!");
      for (final task in unsyncedTask) {
        _taskLocalRepository.updateRowValue(task.id, 1);
      }
    }
  }
}
