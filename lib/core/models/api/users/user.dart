import 'package:json_annotation/json_annotation.dart';
import '../services/service.dart';
import 'customer_profile.dart';
import 'provider_profile.dart';
import 'user_location.dart';
import 'payment_account.dart';
import 'user_stats.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String? id;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? type;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'region_id')
  final String? regionId;
  @JsonKey(name: 'meta_data')
  final Map<String, dynamic>? metaData;
  final UserStats? stats;
  @JsonKey(name: 'customer_profile')
  final CustomerProfile? customerProfile;
  @JsonKey(name: 'provider_profile')
  final ProviderProfile? providerProfile;
  final List<dynamic>? devices;
  final UserLocation? location;
  @JsonKey(name: 'payment_account')
  final PaymentAccount? paymentAccount;

  num? get credibilityScore => stats?.credibilityScore;
  num? get averageRatings => stats?.averageRatings;
  List<Service>? get services => providerProfile?.services;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.type,
    this.isActive,
    this.emailVerified,
    this.phoneVerified,
    this.createdAt,
    this.updatedAt,
    this.regionId,
    this.metaData,
    this.stats,
    this.customerProfile,
    this.providerProfile,
    this.devices,
    this.location,
    this.paymentAccount,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
