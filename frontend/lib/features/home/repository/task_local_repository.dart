import 'package:frontend/models/task_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TaskLocalRepository {
  String tableName = "tasks";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'tasks.db'),
      onCreate: (db, version) {
        return db.execute('''
  CREATE TABLE $tableName(
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    userId TEXT NOT NULL,
    hexColor TEXT NOT NULL,
    completed TEXT NOT NULL,
    description TEXT NOT NULL,
    dueDate TEXT NOT NULL,
    createdAt TEXT NOT NULL,
    updatedAt TEXT NOT NULL,
    isSynced INTEGER NOT NULL
  )
''');
      },
      version: 3,
    );
  }

  Future<void> deleteLocalDb() async {
    final path = await getDatabasesPath();
    await deleteDatabase(join(path, 'tasks.db'));
  }

  Future<void> insertTasks(List<TaskModel> tasks) async {
    final db = await database;
    final batch = db.batch();
    for (var taskModel in tasks) {
      batch.insert(
        tableName,
        taskModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print(tasks);
    }
    await batch.commit(noResult: true);
  }

  Future<void> insertTask(TaskModel taskModel) async {
    final db = await database;
    await db.insert(
      tableName,
      taskModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TaskModel?>> getTasks() async {
    final db = await database;
    final result = await db.query(tableName);
    if (result.isNotEmpty) {
      return result.map((task) => TaskModel.fromMap(task)).toList();
    }
    print(result);
    return [];
  }

  Future<List<TaskModel>> getUnSyncedTask() async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    if (result.isNotEmpty) {
      return result.map((task) => TaskModel.fromMap(task)).toList();
    }
    print(result);
    return [];
  }

  Future<void> updateRowValue(String id, int newVAlue) async {
    final db = await database;
   await db.update(
      tableName,
      {"isSynced": newVAlue},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
