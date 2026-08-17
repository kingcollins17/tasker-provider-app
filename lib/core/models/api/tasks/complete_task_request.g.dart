// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteTaskRequest _$CompleteTaskRequestFromJson(Map<String, dynamic> json) =>
    CompleteTaskRequest(
      pin: json['pin'] as String,
      paymentMode: json['payment_mode'] as String? ?? 'cash',
    );

Map<String, dynamic> _$CompleteTaskRequestToJson(
  CompleteTaskRequest instance,
) => <String, dynamic>{
  'pin': instance.pin,
  'payment_mode': instance.paymentMode,
};
