import 'dart:io';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'support_client.g.dart';

/// A Retrofit API client for customer support endpoints.
@RestApi(baseUrl: "/api/v1/")
abstract class SupportClient {
  factory SupportClient(Dio dio, {String baseUrl}) = _SupportClient;

  @POST("support/cases")
  Future<BaseApiResponse<SupportCase>> createCase(
    @Body() CreateSupportCaseRequest body,
  );

  @GET("support/cases")
  Future<BaseApiResponse<PaginatedData<SupportCase>>> getUserCases({
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
    @Query("task_id") String? taskId,
  });

  @GET("support/cases/{case_id}")
  Future<BaseApiResponse<SupportCase>> getUserCase(
    @Path("case_id") String caseId,
  );

  @GET("support/cases/{case_id}/messages")
  Future<BaseApiResponse<PaginatedData<SupportMessage>>> getCaseMessages(
    @Path("case_id") String caseId, {
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
  });

  @POST("support/cases/{case_id}/messages")
  Future<BaseApiResponse<SupportMessage>> sendUserMessage(
    @Path("case_id") String caseId,
    @Body() SendSupportMessageRequest body,
  );

  @GET("support/cases/{case_id}/timeline")
  Future<BaseApiResponse<PaginatedData<SupportTimelineItem>>> getCaseTimeline(
    @Path("case_id") String caseId, {
    @Query("page") int page = 1,
    @Query("per_page") int perPage = 20,
  });

  @POST("support/cases/{case_id}/attachments")
  @MultiPart()
  Future<BaseApiResponse> uploadCaseAttachment(
    @Path("case_id") String caseId, {
    @Query("message_id") String? messageId,
    @Part(name: "file") required File file,
  });

  @POST("support/cases/{case_id}/close")
  Future<BaseApiResponse> closeUserCase(
    @Path("case_id") String caseId,
  );

  @POST("support/cases/{case_id}/reopen")
  Future<BaseApiResponse> reopenUserCase(
    @Path("case_id") String caseId,
  );
}

/// Provider exposing the [SupportClient] dependency.
final supportClientProvider = Provider<SupportClient>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportClient(dio);
});
