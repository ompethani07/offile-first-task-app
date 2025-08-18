part of "task_cubit.dart";

sealed class TaskState {
  const TaskState();
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class AddNewTaskSuccess extends TaskState {
  final TaskModel taskModel;
  final String message;
  const AddNewTaskSuccess(this.message, this.taskModel);
}

class AddNewTaskError extends TaskState {
  final String errorMessage;
  const AddNewTaskError(this.errorMessage);
}

final class GetTaskSuccess extends TaskState {
  final List<TaskModel> tasks;
  const GetTaskSuccess(this.tasks);
}
