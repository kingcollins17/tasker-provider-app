// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Assignment _$AssignmentFromJson(Map<String, dynamic> json) => Assignment(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  providerId: json['provider_id'] as String?,
  acceptedDispatchAttemptId: json['accepted_dispatch_attempt_id'] as String?,
  acceptedPrice: (json['accepted_price'] as num?)?.toDouble(),
  assignedAt: json['assigned_at'] == null
      ? null
      : DateTime.parse(json['assigned_at'] as String),
  startedAt: json['started_at'] == null
      ? null
      : DateTime.parse(json['started_at'] as String),
  pin: json['pin'] as String?,
  cancellationPin: json['cancellation_pin'] as String?,
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  status: json['status'] as String?,
  task: json['task'] == null
      ? null
      : AssignmentTask.fromJson(json['task'] as Map<String, dynamic>),
  provider: json['provider'] == null
      ? null
      : AssignmentProvider.fromJson(json['provider'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AssignmentToJson(Assignment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'provider_id': instance.providerId,
      'accepted_dispatch_attempt_id': instance.acceptedDispatchAttemptId,
      'accepted_price': instance.acceptedPrice,
      'pin': instance.pin,
      'cancellation_pin': instance.cancellationPin,
      'assigned_at': instance.assignedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'status': instance.status,
      'task': instance.task,
      'provider': instance.provider,
    };

AssignmentTask _$AssignmentTaskFromJson(Map<String, dynamic> json) =>
    AssignmentTask(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      serviceId: json['service_id'] as String?,
      status: json['status'] as String?,
      scheduledStartAt: json['scheduled_start_at'] == null
          ? null
          : DateTime.parse(json['scheduled_start_at'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      providerPayout: (json['provider_payout'] as num?)?.toDouble(),
      customerTotalPrice: (json['customer_total_price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AssignmentTaskToJson(AssignmentTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category_id': instance.categoryId,
      'service_id': instance.serviceId,
      'status': instance.status,
      'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'provider_payout': instance.providerPayout,
      'customer_total_price': instance.customerTotalPrice,
    };

AssignmentProvider _$AssignmentProviderFromJson(Map<String, dynamic> json) =>
    AssignmentProvider(
      id: json['id'] as String?,
      fullname: json['fullname'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      averageRatings: (json['average_ratings'] as num?)?.toDouble(),
      credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      selfieUrl: json['selfie_url'] as String?,
      totalTasksCompleted: (json['total_tasks_completed'] as num?)?.toInt(),
      location: json['location'] == null
          ? null
          : AssignmentProviderLocation.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AssignmentProviderToJson(AssignmentProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_ratings': instance.averageRatings,
      'credibility_score': instance.credibilityScore,
      'gender': instance.gender,
      'profile_picture_url': instance.profilePictureUrl,
      'selfie_url': instance.selfieUrl,
      'total_tasks_completed': instance.totalTasksCompleted,
      'location': instance.location,
    };

AssignmentProviderLocation _$AssignmentProviderLocationFromJson(
  Map<String, dynamic> json,
) => AssignmentProviderLocation(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  regionId: json['region_id'] as String?,
  addressLine: json['address_line'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$AssignmentProviderLocationToJson(
  AssignmentProviderLocation instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'region_id': instance.regionId,
  'address_line': instance.addressLine,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
