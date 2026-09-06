import 'package:json_annotation/json_annotation.dart';

part 'debt.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Debt {
  final double? totalDebtOwed;
  final int? pendingDebtsCount;

  Debt({
    this.totalDebtOwed,
    this.pendingDebtsCount,
  });

  factory Debt.fromJson(Map<String, dynamic> json) => _$DebtFromJson(json);

  Map<String, dynamic> toJson() => _$DebtToJson(this);
}
