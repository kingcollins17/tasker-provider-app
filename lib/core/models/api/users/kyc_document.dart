import 'package:json_annotation/json_annotation.dart';
import 'guarantor.dart';

part 'kyc_document.g.dart';

@JsonSerializable()
class KycDocument {
  final String? id;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'provider_profile_id')
  final String? providerProfileId;

  @JsonKey(name: 'id_type')
  final String? idType;

  @JsonKey(name: 'id_number')
  final String? idNumber;

  @JsonKey(name: 'id_doc_url')
  final String? idDocUrl;

  final String? status;

  @JsonKey(name: 'rejection_reason')
  final String? rejectionReason;

  @JsonKey(name: 'attempt_number')
  final int? attemptNumber;

  @JsonKey(name: 'meta_data')
  final Map<String, dynamic>? metaData;

  @JsonKey(name: 'submitted_at')
  final DateTime? submittedAt;

  @JsonKey(name: 'reviewed_at')
  final DateTime? reviewedAt;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  KycDocument({
    this.id,
    this.userId,
    this.providerProfileId,
    this.idType,
    this.idNumber,
    this.idDocUrl,
    this.status,
    this.rejectionReason,
    this.attemptNumber,
    this.metaData,
    this.submittedAt,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  /// Maps string [status] to [VerificationStatus] enum for clean UI status checking.
  VerificationStatus get verificationStatus {
    final s = status?.toUpperCase().trim();
    switch (s) {
      case 'APPROVED':
      case 'PASSED':
      case 'VERIFIED':
        return VerificationStatus.passed;
      case 'FAILED':
      case 'REJECTED':
        return VerificationStatus.failed;
      case 'SUBMITTED':
      case 'UNDER_REVIEW':
      case 'REVIEW':
      case 'PENDING_ADMIN_REVIEW':
        return VerificationStatus.underReview;
      case 'PENDING':
      case 'PENDING_SUBMISSION':
      default:
        return VerificationStatus.pending;
    }
  }

  factory KycDocument.fromJson(Map<String, dynamic> json) =>
      _$KycDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$KycDocumentToJson(this);
}
