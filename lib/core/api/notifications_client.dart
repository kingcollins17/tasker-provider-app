import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'notifications_client.g.dart';

/// A Retrofit API client for notifications endpoint operations.
@RestApi(baseUrl: "/api/v1/")
abstract class NotificationsClient {
  factory NotificationsClient(Dio dio, {String baseUrl}) = _NotificationsClient;

  @GET("notifications/")
  Future<BaseApiResponse<PaginatedData<NotificationItem>>> getNotifications({
    @Query("page") int? page,
    @Query("per_page") int? perPage,
  });

  @GET("notifications/counts")
  Future<BaseApiResponse<NotificationCounts>> getCounts();

  @POST("notifications/mark-read")
  Future<BaseApiResponse> markAsRead(@Body() MarkReadRequest body);

  @GET("notifications/preferences/")
  Future<BaseApiResponse<List<NotificationPreference>>> getPreferences();

  @PUT("notifications/preferences/")
  Future<BaseApiResponse<List<NotificationPreference>>> updatePreferences(
    @Body() UpdatePreferencesRequest body,
  );
}

/// Provider exposing the [NotificationsClient] dependency.
final notificationsClientProvider = Provider<NotificationsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsClient(dio);
});
