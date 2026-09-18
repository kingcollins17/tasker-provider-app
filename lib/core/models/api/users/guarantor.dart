import 'package:json_annotation/json_annotation.dart';

part 'guarantor.g.dart';

enum VerificationStatus {
  @JsonValue('PENDING')
  pending,

  @JsonValue('PASSED')
  passed,

  @JsonValue('FAILED')
  failed,

  @JsonValue('UNDER_REVIEW')
  underReview;

  String get label {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending Verification';
      case VerificationStatus.passed:
        return 'Verified';
      case VerificationStatus.failed:
        return 'Verification Failed';
      case VerificationStatus.underReview:
        return 'Under Review';
    }
  }
}

@JsonSerializable()
class Guarantor {
  final String? id;

  @JsonKey(name: 'provider_id')
  final String? providerId;

  @JsonKey(name: 'guarantor_name')
  final String? guarantorName;

  @JsonKey(name: 'guarantor_phone')
  final String? guarantorPhone;

  final String? relationship;

  final String? status;

  @JsonKey(name: 'meta_data')
  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  Guarantor({
    this.id,
    this.providerId,
    this.guarantorName,
    this.guarantorPhone,
    this.relationship,
    this.status,
    this.metadata,
    this.verifiedAt,
    this.createdAt,
  });

  /// Maps string [status] to [VerificationStatus] enum for easy status checks.
  VerificationStatus get verificationStatus {
    final s = status?.toUpperCase().trim();
    return switch (s) {
      'PASSED' || 'COMPLETED' => VerificationStatus.passed,
      'UNDER_REVIEW' || 'PENDING_ADMIN_REVIEW' => VerificationStatus.underReview,
      'FAILED' || 'REJECTED' || 'CANCELLED' => VerificationStatus.failed,
      _ => VerificationStatus.pending
    };
    
  }

  factory Guarantor.fromJson(Map<String, dynamic> json) =>
      _$GuarantorFromJson(json);

  Map<String, dynamic> toJson() => _$GuarantorToJson(this);

  /// Extract rejection or failure reason from [metadata] if present.
  String? get failureReason {
    if (metadata == null) return null;
    final reason = metadata!['reason'] ??
        metadata!['rejection_reason'] ??
        metadata!['message'] ??
        metadata!['detail'];
    return reason?.toString();
  }
}
