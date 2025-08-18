import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constants/utils.dart';
import 'package:frontend/core/services/sp_services.dart';
import 'package:frontend/features/auth/cubit/auth_cubit.dart';
import 'package:frontend/features/home/cubit/task_cubit.dart';
import 'package:frontend/features/home/pages/add_new_task_page.dart';
import 'package:frontend/features/home/widgets/date_selector.dart';
import 'package:frontend/features/home/widgets/task_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  static MaterialPageRoute route() =>
      MaterialPageRoute(builder: (context) => HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  @override
  void initState() {
    AuthUserLoggedIn user = context.read<Auth>().state as AuthUserLoggedIn;

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SpServices spService = SpServices();
      final token = await spService.getToken();

      if (token != null) {
        context.read<TaskCubit>().getAllTasks(token: token);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        }
      }
    });
    // 👇 attach the listener
    Connectivity().onConnectivityChanged.listen((results) async {
      if (results.contains(ConnectivityResult.wifi)) {
        final SpServices spService = SpServices();
        final token = await spService.getToken();
        if (token != null) {
          await context.read<TaskCubit>().syncTasks(token);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'My Tasks',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, AddNewTaskPage.route());
            },
            icon: const Icon(CupertinoIcons.add),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AddNewTaskError) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is GetTaskSuccess) {
            final tasks = state.tasks.where((task) {
              return task.dueDate.year == selectedDate.year &&
                  task.dueDate.month == selectedDate.month &&
                  task.dueDate.day == selectedDate.day;
            }).toList();
            return Column(
              children: [
                const SizedBox(height: 10),
                DateSelector(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Row(
                        children: [
                          Expanded(
                            child: TaskCard(
                              color: hexToColor(task.hexColor),
                              headerText: task.title,
                              description: task.description,
                            ),
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: strengthenColor(
                                hexToColor(task.hexColor),
                                0.69,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              DateFormat.jm().format(task.dueDate),
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
