enum TaskStatus { TODO, IN_PROGRESS, COMPLETED }
enum TaskPriority { LOW, MEDIUM, HIGH }

class Task {
  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? dueDate;
  final String createdAt;
  final String updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      dueDate: json['dueDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  static TaskStatus _parseStatus(String s) {
    return TaskStatus.values.firstWhere((e) => e.name == s);
  }

  static TaskPriority _parsePriority(String s) {
    return TaskPriority.values.firstWhere((e) => e.name == s);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate,
    };
  }

  String get statusLabel {
    switch (status) {
      case TaskStatus.TODO:
        return 'À faire';
      case TaskStatus.IN_PROGRESS:
        return 'En cours';
      case TaskStatus.COMPLETED:
        return 'Terminé';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.LOW:
        return 'Basse';
      case TaskPriority.MEDIUM:
        return 'Moyenne';
      case TaskPriority.HIGH:
        return 'Haute';
    }
  }
}