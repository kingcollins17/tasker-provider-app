import 'package:json_annotation/json_annotation.dart';
import '../users/customer_lite.dart';
import 'task_lite.dart';

part 'task.g.dart';

@JsonEnum()
enum PaymentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PAYMENT_REQUESTED')
  paymentRequested,
  @JsonValue('CUSTOMER_PAID')
  customerPaid,
  @JsonValue('TRANSFER_INITIATED')
  transferInitiated,
  @JsonValue('PAID')
  paid,
  @JsonValue('CASH_PAID')
  cashPaid,
  @JsonValue('FAILED')
  failed,
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class TaskPayout {
  final String? id;
  final String? providerId;
  final String? customerId;
  final String? taskId;
  final double? payoutAmount;
  final double? customerPaymentAmount;
  final String? status;
  final String? description;
  final String? paymentUrl;
  final DateTime? urlGeneratedAt;
  final String? reference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TaskLite? task;

  TaskPayout({
    this.id,
    this.providerId,
    this.customerId,
    this.taskId,
    this.payoutAmount,
    this.customerPaymentAmount,
    this.status,
    this.description,
    this.paymentUrl,
    this.urlGeneratedAt,
    this.reference,
    this.createdAt,
    this.updatedAt,
    this.task,
  });

  factory TaskPayout.fromJson(Map<String, dynamic> json) =>
      _$TaskPayoutFromJson(json);

  Map<String, dynamic> toJson() => _$TaskPayoutToJson(this);
}

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
  final String? paymentStatus;
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
  final TaskPayout? payout;

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
    this.paymentStatus,
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
    this.payout,
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


