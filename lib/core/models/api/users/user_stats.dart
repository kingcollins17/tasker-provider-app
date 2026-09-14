import 'package:json_annotation/json_annotation.dart';

part 'user_stats.g.dart';

@JsonSerializable()
class UserStats {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'credibility_score')
  final num? credibilityScore;
  @JsonKey(name: 'average_ratings')
  final num? averageRatings;
  @JsonKey(name: 'total_ratings')
  final num? totalRatings;
  @JsonKey(name: 'acceptance_rate_30d')
  final num? acceptanceRate30d;
  @JsonKey(name: 'completion_rate_30d')
  final num? completionRate30d;
  @JsonKey(name: 'current_tier')
  final int? currentTier;
  @JsonKey(name: 'total_tasks_completed')
  final int? totalTasksCompleted;
  @JsonKey(name: 'total_tasks_posted')
  final int? totalTasksPosted;
  @JsonKey(name: 'consecutive_declines')
  final int? consecutiveDeclines;
  @JsonKey(name: 'cancellation_count')
  final int? cancellationCount;

  UserStats({
    this.id,
    this.userId,
    this.credibilityScore,
    this.averageRatings,
    this.totalRatings,
    this.acceptanceRate30d,
    this.completionRate30d,
    this.currentTier,
    this.totalTasksCompleted,
    this.totalTasksPosted,
    this.consecutiveDeclines,
    this.cancellationCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}
