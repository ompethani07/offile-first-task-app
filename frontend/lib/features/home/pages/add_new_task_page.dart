import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/sp_services.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/task_cubit.dart';
import 'package:frontend/features/home/pages/home_page.dart';

class AddNewTaskPage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => const AddNewTaskPage());

  const AddNewTaskPage({super.key});

  @override
  State<AddNewTaskPage> createState() => _AddNewTaskPageState();
}

class _AddNewTaskPageState extends State<AddNewTaskPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();

  DateTime selectedDate = DateTime.now();
  Color selectedColor = const Color.fromRGBO(246, 222, 194, 1);

  /// Create a new task and call TaskCubit
  void createNewTask() async {
    if (formKey.currentState!.validate()) {
      AuthUserLoggedIn user = context.read<Auth>().state as AuthUserLoggedIn;

      final SpServices spService = SpServices();
      String? token = await spService.getToken();

      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      await context.read<TaskCubit>().createTask(
        userId: user.user.id,
        title: taskTitleController.text,
        description: taskDescriptionController.text,
        dueDate: selectedDate,
        color: selectedColor,
        token: token,
      );
    }
  }

  @override
  void dispose() {
    taskTitleController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Task'),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                initialDate: selectedDate,
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),

      /// Use BlocConsumer to listen & build UI
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is AddNewTaskSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));

            // ✅ Navigation happens in listener, not in builder
            Navigator.pushAndRemoveUntil(
              context,
              HomePage.route(),
              (_) => false,
            );
          } else if (state is AddNewTaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: taskTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'Enter the title of the task',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a task title'
                          : null,
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: taskDescriptionController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Task Description',
                        hintText: 'Enter the description of the task',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a task description'
                          : null,
                    ),

                    const SizedBox(height: 10),

                    ColorPicker(
                      heading: const Text('Pick a color for the task'),
                      subheading: const Text(
                        'Select a color for the task card',
                      ),
                      onColorChanged: (Color color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      color: selectedColor,
                      pickersEnabled: const {ColorPickerType.wheel: true},
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: createNewTask,
                      child: const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
