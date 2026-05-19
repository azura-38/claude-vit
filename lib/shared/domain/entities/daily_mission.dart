class DailyMission {
  final String id;
  final String title;
  final int target;
  final int progress;
  final bool isCompleted;

  const DailyMission({
    required this.id,
    required this.title,
    required this.target,
    required this.progress,
    required this.isCompleted,
  });

  DailyMission copyWith({int? progress, bool? isCompleted}) {
    return DailyMission(
      id: id,
      title: title,
      target: target,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target': target,
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }

  factory DailyMission.fromMap(Map<String, dynamic> map) {
    return DailyMission(
      id: map['id'],
      title: map['title'],
      target: map['target'],
      progress: map['progress'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
