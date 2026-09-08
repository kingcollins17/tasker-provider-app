import 'package:json_annotation/json_annotation.dart';

part 'submit_review_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SubmitReviewRequest {
  final String taskId;
  final int rating;
  final String? comment;

  SubmitReviewRequest({
    required this.taskId,
    required this.rating,
    this.comment,
  });

  factory SubmitReviewRequest.fromJson(Map<String, dynamic> json) =>
      _$SubmitReviewRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SubmitReviewRequestToJson(this);
}
