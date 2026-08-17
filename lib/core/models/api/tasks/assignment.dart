import 'package:json_annotation/json_annotation.dart';

part 'assignment.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Assignment {
  final String? id;
  final String? taskId;
  final String? providerId;
  final String? acceptedDispatchAttemptId;
  final double? acceptedPrice;
  final String? pin;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? status;
  final AssignmentTask? task;
  final AssignmentProvider? provider;

  Assignment({
    this.id,
    this.taskId,
    this.providerId,
    this.acceptedDispatchAttemptId,
    this.acceptedPrice,
    this.assignedAt,
    this.startedAt,
    this.pin,
    this.completedAt,
    this.status,
    this.task,
    this.provider,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssignmentTask {
  final String? id;
  final String? title;
  final String? description;
  final String? categoryId;
  final String? serviceId;
  final String? status;
  final DateTime? scheduledStartAt;
  final DateTime? createdAt;
  final double? providerPayout;
  final double? customerTotalPrice;

  AssignmentTask({
    this.id,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.status,
    this.scheduledStartAt,
    this.createdAt,
    this.providerPayout,
    this.customerTotalPrice,
  });

  factory AssignmentTask.fromJson(Map<String, dynamic> json) =>
      _$AssignmentTaskFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentTaskToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssignmentProvider {
  final String? id;
  final String? fullname;
  final String? email;
  final String? phoneNumber;
  final double? averageRatings;
  final double? credibilityScore;
  final String? gender;
  final String? profilePictureUrl;
  final String? selfieUrl;
  final int? totalTasksCompleted;
  final AssignmentProviderLocation? location;

  AssignmentProvider({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
    this.profilePictureUrl,
    this.selfieUrl,
    this.totalTasksCompleted,
    this.location,
  });

  factory AssignmentProvider.fromJson(Map<String, dynamic> json) =>
      _$AssignmentProviderFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentProviderToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssignmentProviderLocation {
  final String? id;
  final String? userId;
  final String? regionId;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssignmentProviderLocation({
    this.id,
    this.userId,
    this.regionId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory AssignmentProviderLocation.fromJson(Map<String, dynamic> json) =>
      _$AssignmentProviderLocationFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentProviderLocationToJson(this);
}
