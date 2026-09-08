// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submit_review_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitReviewRequest _$SubmitReviewRequestFromJson(Map<String, dynamic> json) =>
    SubmitReviewRequest(
      taskId: json['task_id'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$SubmitReviewRequestToJson(
  SubmitReviewRequest instance,
) => <String, dynamic>{
  'task_id': instance.taskId,
  'rating': instance.rating,
  'comment': instance.comment,
};
