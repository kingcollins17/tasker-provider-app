// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Debt _$DebtFromJson(Map<String, dynamic> json) => Debt(
  totalDebtOwed: (json['total_debt_owed'] as num?)?.toDouble(),
  pendingDebtsCount: (json['pending_debts_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$DebtToJson(Debt instance) => <String, dynamic>{
  'total_debt_owed': instance.totalDebtOwed,
  'pending_debts_count': instance.pendingDebtsCount,
};
