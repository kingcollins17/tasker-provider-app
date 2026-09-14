// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  credibilityScore: json['credibility_score'] as num?,
  averageRatings: json['average_ratings'] as num?,
  totalRatings: json['total_ratings'] as num?,
  acceptanceRate30d: json['acceptance_rate_30d'] as num?,
  completionRate30d: json['completion_rate_30d'] as num?,
  currentTier: (json['current_tier'] as num?)?.toInt(),
  totalTasksCompleted: (json['total_tasks_completed'] as num?)?.toInt(),
  totalTasksPosted: (json['total_tasks_posted'] as num?)?.toInt(),
  consecutiveDeclines: (json['consecutive_declines'] as num?)?.toInt(),
  cancellationCount: (json['cancellation_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'credibility_score': instance.credibilityScore,
  'average_ratings': instance.averageRatings,
  'total_ratings': instance.totalRatings,
  'acceptance_rate_30d': instance.acceptanceRate30d,
  'completion_rate_30d': instance.completionRate30d,
  'current_tier': instance.currentTier,
  'total_tasks_completed': instance.totalTasksCompleted,
  'total_tasks_posted': instance.totalTasksPosted,
  'consecutive_declines': instance.consecutiveDeclines,
  'cancellation_count': instance.cancellationCount,
};
