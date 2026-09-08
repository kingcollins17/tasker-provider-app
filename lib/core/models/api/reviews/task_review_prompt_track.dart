/// Model tracking when a review bottom sheet was last shown for a given task.
class TaskReviewPromptTrack {
  final String taskId;
  final DateTime? lastShownAt;

  const TaskReviewPromptTrack({
    required this.taskId,
    this.lastShownAt,
  });

  /// Deserializes a [TaskReviewPromptTrack] from a JSON map manually without code generation.
  factory TaskReviewPromptTrack.fromJson(Map<String, dynamic> json) {
    final rawDate = json['last_shown_at'] ?? json['lastShownAt'];
    DateTime? parsedDate;
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    return TaskReviewPromptTrack(
      taskId: (json['task_id'] ?? json['taskId']) as String? ?? '',
      lastShownAt: parsedDate,
    );
  }

  /// Serializes this model into a JSON map manually without code generation.
  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'last_shown_at': lastShownAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [TaskReviewPromptTrack] with optional updated fields.
  TaskReviewPromptTrack copyWith({
    String? taskId,
    DateTime? lastShownAt,
  }) {
    return TaskReviewPromptTrack(
      taskId: taskId ?? this.taskId,
      lastShownAt: lastShownAt ?? this.lastShownAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskReviewPromptTrack &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          lastShownAt == other.lastShownAt;

  @override
  int get hashCode => taskId.hashCode ^ lastShownAt.hashCode;

  @override
  String toString() {
    return 'TaskReviewPromptTrack(taskId: $taskId, lastShownAt: $lastShownAt)';
  }
}
