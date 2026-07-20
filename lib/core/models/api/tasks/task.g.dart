// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String?,
  customerId: json['customer_id'] as String?,
  regionId: json['region_id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  serviceId: json['service_id'] as String?,
  budgetMin: (json['budget_min'] as num?)?.toDouble(),
  budgetMax: (json['budget_max'] as num?)?.toDouble(),
  pricingModel: json['pricing_model'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  scheduledStartAt: json['scheduled_start_at'] == null
      ? null
      : DateTime.parse(json['scheduled_start_at'] as String),
  startPin: json['start_pin'] as String?,
  completionPin: json['completion_pin'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  locations: (json['locations'] as List<dynamic>?)
      ?.map((e) => TaskLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  assignment: json['assignment'] == null
      ? null
      : TaskAssignment.fromJson(json['assignment'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => TaskAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  customer: json['customer'] == null
      ? null
      : CustomerLite.fromJson(json['customer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'region_id': instance.regionId,
  'title': instance.title,
  'description': instance.description,
  'category_id': instance.categoryId,
  'service_id': instance.serviceId,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'pricing_model': instance.pricingModel,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
  'start_pin': instance.startPin,
  'completion_pin': instance.completionPin,
  'updated_at': instance.updatedAt?.toIso8601String(),
  'locations': instance.locations,
  'assignment': instance.assignment,
  'attachments': instance.attachments,
  'customer': instance.customer,
};

TaskLocation _$TaskLocationFromJson(Map<String, dynamic> json) => TaskLocation(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  locationType: json['location_type'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TaskLocationToJson(TaskLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'location_type': instance.locationType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'distance_km': instance.distanceKm,
    };

TaskBid _$TaskBidFromJson(Map<String, dynamic> json) => TaskBid(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  providerId: json['provider_id'] as String?,
  price: (json['price'] as num?)?.toDouble(),
  message: json['message'] as String?,
  estimatedDuration: json['estimated_duration'] as String?,
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  task: json['task'] == null
      ? null
      : TaskLite.fromJson(json['task'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskBidToJson(TaskBid instance) => <String, dynamic>{
  'id': instance.id,
  'task_id': instance.taskId,
  'provider_id': instance.providerId,
  'price': instance.price,
  'message': instance.message,
  'estimated_duration': instance.estimatedDuration,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'task': instance.task,
};

TaskAssignment _$TaskAssignmentFromJson(Map<String, dynamic> json) =>
    TaskAssignment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      providerId: json['provider_id'] as String?,
      acceptedBidId: json['accepted_bid_id'] as String?,
      acceptedPrice: (json['accepted_price'] as num?)?.toDouble(),
      assignedAt: json['assigned_at'] == null
          ? null
          : DateTime.parse(json['assigned_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$TaskAssignmentToJson(TaskAssignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'provider_id': instance.providerId,
      'accepted_bid_id': instance.acceptedBidId,
      'accepted_price': instance.acceptedPrice,
      'assigned_at': instance.assignedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'status': instance.status,
    };

TaskAttachment _$TaskAttachmentFromJson(Map<String, dynamic> json) =>
    TaskAttachment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      storageKey: json['storage_key'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      type: json['type'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaskAttachmentToJson(TaskAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'storage_key': instance.storageKey,
      'file_name': instance.fileName,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'url': instance.url,
      'type': instance.type,
      'created_at': instance.createdAt?.toIso8601String(),
    };

CreateBidRequest _$CreateBidRequestFromJson(Map<String, dynamic> json) =>
    CreateBidRequest(
      price: (json['price'] as num?)?.toDouble(),
      message: json['message'] as String?,
      estimatedDuration: json['estimated_duration'] as String?,
    );

Map<String, dynamic> _$CreateBidRequestToJson(CreateBidRequest instance) =>
    <String, dynamic>{
      'price': instance.price,
      'message': instance.message,
      'estimated_duration': instance.estimatedDuration,
    };
