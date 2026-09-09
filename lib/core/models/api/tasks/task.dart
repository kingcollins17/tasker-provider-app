import 'package:json_annotation/json_annotation.dart';
import '../users/customer_lite.dart';
import 'task_lite.dart';

part 'task.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class Task {
  final String? id;
  final String? customerId;
  final String? assignedProviderId;
  final String? regionId;
  final String? title;
  final String? description;
  final String? categoryId;
  final String? serviceId;
  final double? basePrice;
  final double? distanceFee;
  final double? timeFee;
  final double? urgencyFee;
  final double? complexityFee;
  final double? surgeMultiplier;
  final double? customerTotalPrice;
  final double? platformFee;
  final double? providerPayout;
  final String? status;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final DateTime? scheduledStartAt;
  final String? startPin;
  final String? completionPin;
  final DateTime? updatedAt;
  final List<TaskLocation>? locations;

  final TaskAssignment? assignment;
  final List<TaskAttachment>? attachments;
  final CustomerLite? customer;

  Task({
    this.id,
    this.customerId,
    this.assignedProviderId,
    this.regionId,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.basePrice,
    this.distanceFee,
    this.timeFee,
    this.urgencyFee,
    this.complexityFee,
    this.surgeMultiplier,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.expiresAt,
    this.scheduledStartAt,
    this.startPin,
    this.completionPin,
    this.updatedAt,
    this.locations,
    this.assignment,
    this.attachments,
    this.customer,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskLocation {
  final String? id;
  final String? taskId;
  final String? locationType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? distanceKm;

  TaskLocation({
    this.id,
    this.taskId,
    this.locationType,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.distanceKm,
  });

  factory TaskLocation.fromJson(Map<String, dynamic> json) =>
      _$TaskLocationFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLocationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskBid {
  final String? id;
  final String? taskId;
  final String? providerId;
  final double? price;
  final String? message;
  final String? estimatedDuration;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskLite? task;

  TaskBid({
    this.id,
    this.taskId,
    this.providerId,
    this.price,
    this.message,
    this.estimatedDuration,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory TaskBid.fromJson(Map<String, dynamic> json) =>
      _$TaskBidFromJson(json);

  Map<String, dynamic> toJson() => _$TaskBidToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskAssignment {
  final String? id;
  final String? taskId;
  final String? providerId;
  final String? acceptedBidId;
  final double? acceptedPrice;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? status;

  TaskAssignment({
    this.id,
    this.taskId,
    this.providerId,
    this.acceptedBidId,
    this.acceptedPrice,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.status,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAssignmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TaskAttachment {
  final String? id;
  final String? taskId;
  final String? storageKey;
  final String? fileName;
  final int? fileSize;
  final String? mimeType;
  final String? url;
  final String? type;
  final DateTime? createdAt;

  TaskAttachment({
    this.id,
    this.taskId,
    this.storageKey,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.url,
    this.type,
    this.createdAt,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAttachmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateBidRequest {
  final double? price;
  final String? message;
  final String? estimatedDuration;

  CreateBidRequest({
    required this.price,
    required this.message,
    this.estimatedDuration,
  });

  factory CreateBidRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateBidRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBidRequestToJson(this);
}

typedef UpdateBidRequest = CreateBidRequest;
