// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TaskModel {
  final String id;
  final String userId; // add userId to match backend
  final String title;
  final String description;
  final DateTime dueDate;
  final String hexColor;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt; 
  final int isSynced;

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.hexColor,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? hexColor,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hexColor: hexColor ?? this.hexColor,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'hexColor': hexColor,
      'completed': completed ? "true" : "false", // backend expects string
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      "isSynced": isSynced,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? "",
      userId: map['userId'] ?? "",
      title: map['title'] ?? "",
      description: map['description'] ?? "",
      dueDate: DateTime.parse(map['dueDate']),
      hexColor: map['hexColor'] ?? "",
      completed: map['completed'] == "true", // convert string → bool
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] ?? 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TaskModel(id: $id, userId: $userId, title: $title, description: $description, dueDate: $dueDate, hexColor: $hexColor, completed: $completed, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant TaskModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.dueDate == dueDate &&
        other.hexColor == hexColor &&
        other.completed == completed &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        dueDate.hashCode ^
        hexColor.hashCode ^
        completed.hashCode ^
        createdAt.hashCode ^
        isSynced.hashCode ^
        updatedAt.hashCode;
  }
}
