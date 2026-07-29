import 'dart:io';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'users_client.g.dart';

/// A Retrofit API client for users endpoint operations.
@RestApi(baseUrl: "/api/v1/")
abstract class UsersClient {
  factory UsersClient(Dio dio, {String baseUrl}) = _UsersClient;

  @POST("users/register")
  Future<BaseApiResponse> register(@Body() RegisterRequest body);

  @POST("users/login")
  @FormUrlEncoded()
  Future<LoginResponse> login({
    @Field("grant_type") String? grantType,
    @Field("username") required String username,
    @Field("password") required String password,
    @Field("scope") String? scope,
    @Field("client_id") String? clientId,
    @Field("client_secret") String? clientSecret,
  });

  @POST("users/request-email-otp")
  Future<BaseApiResponse> requestEmailOtp(@Body() RequestEmailOtpRequest body);

  @POST("users/request-phone-otp")
  Future<BaseApiResponse> requestPhoneOtp(@Body() RequestPhoneOtpRequest body);

  @POST("users/verify-email")
  Future<BaseApiResponse> verifyEmail(@Body() VerifyEmailRequest body);

  @POST("users/verify-phone")
  Future<BaseApiResponse> verifyPhone(@Body() VerifyPhoneRequest body);

  @POST("users/verify-otp")
  Future<BaseApiResponse> verifyOtp(@Body() VerifyOtpRequest body);

  @GET("users/me")
  Future<BaseApiResponse<User>> getMe();

  @GET("regions/")
  Future<BaseApiResponse<List<Region>>> getRegions();

  @PUT("users/location")
  Future<BaseApiResponse> updateLocation(@Body() UpdateLocationRequest body);

  @PUT("users/update-provider-profile")
  Future<BaseApiResponse> updateProviderProfile(@Body() UpdateProviderProfileRequest body);

  @PUT("users/region")
  Future<BaseApiResponse> updateRegion(@Body() UpdateRegionRequest body);

  @PUT("users/online-status")
  Future<BaseApiResponse> updateOnlineStatus(@Body() UpdateOnlineStatusRequest body);

  @POST("users/location/ping")
  Future<BaseApiResponse> pingLocation(@Body() PingLocationRequest body);

  @POST("users/provider/services")
  Future<BaseApiResponse> addProviderService(@Body() AddServiceRequest body);

  @DELETE("users/provider/services/{service_id}")
  Future<BaseApiResponse> removeProviderService(
    @Path("service_id") String serviceId,
  );

  @POST("users/kyc/selfie")
  @MultiPart()
  Future<BaseApiResponse> submitKycSelfie({
    @Part(name: "selfie") required File selfie,
  });

  @POST("users/kyc/document")
  @MultiPart()
  Future<BaseApiResponse> submitKycDocument({
    @Part(name: "id_type") required String idType,
    @Part(name: "id_number") required String idNumber,
    @Part(name: "id_doc") required File idDoc,
  });

  @GET("users/provider/availability")
  Future<BaseApiResponse<List<ProviderAvailability>>> getProviderAvailability();

  @PUT("users/provider/availability/{availability_id}")
  Future<BaseApiResponse> updateProviderAvailability(
    @Path("availability_id") String availabilityId,
    @Body() UpdateAvailabilityRequest body,
  );

  @POST("users/provider/availability/default")
  Future<BaseApiResponse<List<ProviderAvailability>>> createDefaultProviderAvailability();
}

/// Provider exposing the [UsersClient] dependency.
final usersClientProvider = Provider<UsersClient>((ref) {
  final dio = ref.watch(dioProvider);
  return UsersClient(dio);
});
