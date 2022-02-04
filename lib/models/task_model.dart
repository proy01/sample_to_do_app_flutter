class Task {
  final String title;
  final String? description;
  int duration;
  int completed;
  final int id;

  Task(
      {required this.id,
      this.description,
      required this.title,
      this.duration = 600,
      this.completed = 0});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'completed': completed
    };
  }

  @override
  String toString() {
    return "Task{id: $id, title: $title, description: $description, duration: $duration, completed: $completed}";
  }
}
